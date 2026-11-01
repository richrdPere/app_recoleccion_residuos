import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:app_recoleccion_residuos/src/config/constants/environment.dart';

enum AppSocketStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  authenticationRequired,
}

class AppSocketEvent {
  final String name;
  final String userId;
  final Map<String, dynamic> data;

  const AppSocketEvent({
    required this.name,
    required this.userId,
    required this.data,
  });
}

class AppSocketService {
  AppSocketService._();

  static final AppSocketService instance = AppSocketService._();

  final StreamController<AppSocketStatus> _statusController =
      StreamController<AppSocketStatus>.broadcast();

  final StreamController<AppSocketEvent> _eventsController =
      StreamController<AppSocketEvent>.broadcast();

  io.Socket? _socket;

  Timer? _reconnectTimer;

  String? _userId;
  String? _accessToken;

  int _generation = 0;
  int _retrySeconds = 1;

  bool _authenticationBlocked = false;

  AppSocketStatus _status = AppSocketStatus.disconnected;

  Stream<AppSocketStatus> get statuses => _statusController.stream;

  Stream<AppSocketEvent> get events => _eventsController.stream;

  AppSocketStatus get status => _status;

  bool get connected => _socket?.connected == true;

  bool get waitingForAuthentication => _authenticationBlocked;

  // ==========================================================
  // VINCULAR CON LA SESIÓN
  // ==========================================================

  void setSession({required String userId, required String accessToken}) {
    final normalizedUser = userId.trim();

    final normalizedToken = accessToken.trim().replaceFirst(
      RegExp(r'^Bearer\s+', caseSensitive: false),
      '',
    );

    if (normalizedUser.isEmpty || normalizedToken.isEmpty) {
      disconnect();
      return;
    }

    final sameSession =
        _userId == normalizedUser && _accessToken == normalizedToken;

    if (sameSession) {
      if (!_authenticationBlocked &&
          _socket == null &&
          _reconnectTimer == null) {
        _open();
      }

      return;
    }

    // Cambió el usuario o el JWT:
    // invalidar todos los callbacks anteriores.
    _generation++;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _destroySocket();

    _userId = normalizedUser;
    _accessToken = normalizedToken;

    _authenticationBlocked = false;
    _retrySeconds = 1;

    _open();
  }

  // Se utiliza al regresar a primer plano.
  void ensureConnected() {
    if (_userId == null ||
        _accessToken == null ||
        _authenticationBlocked ||
        connected) {
      return;
    }

    // Si existe un intento en curso o un reintento programado,
    // no crear otra conexión simultánea.
    if (_status == AppSocketStatus.connecting || _reconnectTimer != null) {
      return;
    }

    _open();
  }

  // ==========================================================
  // CREAR LA CONEXIÓN
  // ==========================================================

  void _open() {
    final userId = _userId;
    final token = _accessToken;

    if (userId == null || token == null || _authenticationBlocked) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final generation = ++_generation;

    _destroySocket();

    _setStatus(AppSocketStatus.connecting);

    final socket = io.io(Environment.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'path': '/socket.io',
      'autoConnect': false,

      // La reconexión la controla este servicio
      // para mantener una sola conexión y el JWT vigente.
      'reconnection': false,

      // Evitar reutilizar un Manager con credenciales antiguas.
      'forceNew': true,
      'multiplex': false,

      'timeout': 15000,

      // Coincide con socket.handshake.auth.token del backend.
      'auth': {'token': token},
    });

    _socket = socket;

    bool isCurrent() {
      return identical(_socket, socket) &&
          generation == _generation &&
          _userId == userId &&
          _accessToken == token;
    }

    socket.onConnect((_) {
      if (!isCurrent()) return;

      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      _retrySeconds = 1;

      _setStatus(AppSocketStatus.connected);
    });

    socket.onDisconnect((_) {
      if (!isCurrent()) return;

      if (_authenticationBlocked) return;

      _setStatus(AppSocketStatus.disconnected);

      _scheduleReconnect();
    });

    socket.onConnectError((error) {
      if (!isCurrent()) return;

      if (_isAuthenticationError(error)) {
        _requireAuthentication();
        return;
      }

      _scheduleReconnect();
    });

    socket.on('auth:error', (data) {
      if (!isCurrent()) return;

      if (_isAuthenticationError(data)) {
        _requireAuthentication();
      } else {
        // Un fallo temporal del backend no debe
        // cerrar la sesión REST del usuario.
        _scheduleReconnect();
      }
    });

    socket.on('socket:error', (data) {
      if (!isCurrent()) return;

      if (_isAuthenticationError(data)) {
        _requireAuthentication();
      }
    });

    // Eventos reales de tu backend.
    const notificationEvents = <String>[
      'notificacion:nueva',
      'notificacion:leida',
      'notificacion:todas-leidas',
      'notificacion:archivada',

      // Compatibilidad con global.sendNotification.
      'notificacion',
    ];

    for (final event in notificationEvents) {
      socket.on(event, (payload) {
        if (!isCurrent() || !socket.connected) return;

        _eventsController.add(
          AppSocketEvent(name: event, userId: userId, data: _asMap(payload)),
        );
      });
    }

    socket.connect();
  }

  // ==========================================================
  // RECONEXIÓN CON ESPERA PROGRESIVA
  // ==========================================================

  void _scheduleReconnect() {
    if (_userId == null ||
        _accessToken == null ||
        _authenticationBlocked ||
        _reconnectTimer != null) {
      return;
    }

    _setStatus(AppSocketStatus.reconnecting);

    final delay = _retrySeconds;

    _retrySeconds = _retrySeconds >= 15 ? 30 : _retrySeconds * 2;

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _reconnectTimer = null;

      if (_userId == null || _accessToken == null || _authenticationBlocked) {
        return;
      }

      _open();
    });
  }

  // ==========================================================
  // JWT RECHAZADO O VENCIDO
  // ==========================================================

  void _requireAuthentication() {
    _authenticationBlocked = true;

    _generation++;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _destroySocket();

    // No reintentar con el mismo JWT rechazado.
    // SocketSessionListener solicita renovación mediante REST.
    _setStatus(AppSocketStatus.authenticationRequired);
  }

  bool _isAuthenticationError(dynamic raw) {
    final map = _asMap(raw);
    final nested = _asMap(map['data']);

    final code = (map['code'] ?? nested['code'] ?? '').toString();

    final statusCode = int.tryParse(
      '${map['statusCode'] ?? nested['statusCode'] ?? ''}',
    );

    if (statusCode == 401) return true;

    return const <String>{
      'ACCESS_TOKEN_REQUIRED',
      'INVALID_ACCESS_TOKEN_TYPE',
      'INVALID_ACCESS_TOKEN_PAYLOAD',
      'ACCESS_TOKEN_EXPIRED',
      'INVALID_ACCESS_TOKEN',
      'ACCESS_TOKEN_NOT_ACTIVE',
      'SESSION_REVOKED',
      'UNAUTHORIZED',
    }.contains(code);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        // El mensaje puede ser texto simple.
      }
    }

    return <String, dynamic>{};
  }

  // ==========================================================
  // DESCONEXIÓN Y LIMPIEZA
  // ==========================================================

  void disconnect() {
    _generation++;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _userId = null;
    _accessToken = null;

    _authenticationBlocked = false;
    _retrySeconds = 1;

    _destroySocket();

    _setStatus(AppSocketStatus.disconnected);
  }

  void _destroySocket() {
    final socket = _socket;

    _socket = null;

    socket?.dispose();
  }

  void _setStatus(AppSocketStatus status) {
    if (_status == status) return;

    _status = status;
    _statusController.add(status);
  }
}
