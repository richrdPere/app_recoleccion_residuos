import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_event.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_state.dart';
import 'package:app_recoleccion_residuos/src/config/router/app_router.dart';

import 'package:app_recoleccion_residuos/src/data/datasources/remote/socket/app_socket_service.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_cubit.dart';

class SocketSessionListener extends StatefulWidget {
  final Widget child;

  const SocketSessionListener({super.key, required this.child});

  @override
  State<SocketSessionListener> createState() => _SocketSessionListenerState();
}

class _SocketSessionListenerState extends State<SocketSessionListener>
    with WidgetsBindingObserver {
  final AppSocketService _socket = AppSocketService.instance;

  StreamSubscription<AppSocketStatus>? _statusSubscription;
  StreamSubscription<AppSocketEvent>? _eventsSubscription;

  Timer? _refreshTimer;
  Timer? _authenticationTimer;

  bool _refreshing = false;
  bool _dirty = false;

  DateTime? _lastRefreshAttempt;

  String? _lastUserId;

  bool get _resumed {
    final lifecycle = WidgetsBinding.instance.lifecycleState;

    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Suscribir antes de iniciar la conexión.
    _statusSubscription = _socket.statuses.listen(_onSocketStatus);

    _eventsSubscription = _socket.events.listen(_onSocketEvent);

    // Si una renovación falló temporalmente, permite
    // reintentarla mientras la app está en primer plano.
    _authenticationTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted || !_resumed) return;

      if (_socket.waitingForAuthentication) {
        _requestTokenRefresh();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _syncSession(context.read<SessionBloc>().state);
    });
  }

  // ==========================================================
  // SESIÓN REST → SESIÓN SOCKET
  // ==========================================================

  void _syncSession(SessionState state) {
    if (state.isAuthenticated) {
      final session = state.session!;

      final userId = session.usuario.idUsuario.toString();

      if (_lastUserId != userId) {
        _lastUserId = userId;
        _lastRefreshAttempt = null;
      }

      _socket.setSession(userId: userId, accessToken: session.accessToken);

      return;
    }

    if (state.status == SessionStatus.loggingOut ||
        state.status == SessionStatus.unauthenticated) {
      _lastUserId = null;
      _lastRefreshAttempt = null;

      _dirty = false;

      _refreshTimer?.cancel();
      _refreshTimer = null;

      _socket.disconnect();
    }

    // No cerrar por estados transitorios de restauración
    // o guardado de sesión.
  }

  // ==========================================================
  // ESTADO DE LA CONEXIÓN
  // ==========================================================

  void _onSocketStatus(AppSocketStatus status) {
    if (!mounted) return;

    switch (status) {
      case AppSocketStatus.connected:
        debugPrint('[socket] Conectado.');

        // Recuperar cambios que pudieron ocurrir
        // mientras el socket estaba desconectado.
        _scheduleInboxRefresh();

        break;

      case AppSocketStatus.authenticationRequired:
        debugPrint('[socket] Se requiere renovar la autenticación.');

        _requestTokenRefresh();

        break;

      case AppSocketStatus.connecting:
      case AppSocketStatus.reconnecting:
      case AppSocketStatus.disconnected:
        break;
    }
  }

  void _requestTokenRefresh() {
    if (!mounted || !_resumed) return;

    final sessionBloc = context.read<SessionBloc>();
    final state = sessionBloc.state;

    if (sessionBloc.isClosed || !state.isAuthenticated || state.isLoading) {
      return;
    }

    final now = DateTime.now();
    final previous = _lastRefreshAttempt;

    // AuthListener también administra renovaciones.
    // Evitar solicitudes repetidas desde este listener.
    if (previous != null &&
        now.difference(previous) < const Duration(seconds: 30)) {
      return;
    }

    _lastRefreshAttempt = now;

    sessionBloc.add(const SessionRefreshRequested());
  }

  // ==========================================================
  // EVENTOS DE NOTIFICACIONES
  // ==========================================================

  void _onSocketEvent(AppSocketEvent event) {
    if (!mounted) return;

    final session = context.read<SessionBloc>().state;

    if (!session.isAuthenticated) return;

    final currentUser = session.session!.usuario.idUsuario.toString();

    // Ignorar eventos de una conexión anterior.
    if (event.userId != currentUser) return;

    switch (event.name) {
      case 'notificacion:nueva':
      case 'notificacion:leida':
      case 'notificacion:todas-leidas':
      case 'notificacion:archivada':
      case 'notificacion':
        _scheduleInboxRefresh();
        break;
    }

    // Aquí no mostramos otra notificación local.
    // Esa presentación continúa a cargo de FCM.
  }

  // ==========================================================
  // AGRUPAR ACTUALIZACIONES DE BANDEJA
  // ==========================================================

  void _scheduleInboxRefresh() {
    if (!mounted) return;

    _dirty = true;

    if (!_resumed || _refreshing || _refreshTimer != null) {
      return;
    }

    _refreshTimer = Timer(const Duration(milliseconds: 300), () {
      _refreshTimer = null;
      unawaited(_flushInboxRefresh());
    });
  }

  Future<void> _flushInboxRefresh() async {
    if (!mounted || !_resumed || !_dirty || _refreshing) {
      return;
    }

    final session = context.read<SessionBloc>().state;

    if (!session.isAuthenticated) {
      _dirty = false;
      return;
    }

    final cubit = context.read<NotificacionesCubit>();

    if (cubit.isClosed) return;

    final userId = session.session!.usuario.idUsuario.toString();

    cubit.bindSession(userId);

    // No interrumpir una lectura, archivo o paginación
    // que esté ejecutándose desde la interfaz.
    if (cubit.state.loading ||
        cubit.state.loadingMore ||
        cubit.state.mutating) {
      _refreshTimer = Timer(const Duration(milliseconds: 500), () {
        _refreshTimer = null;
        unawaited(_flushInboxRefresh());
      });

      return;
    }

    _refreshing = true;
    _dirty = false;

    try {
      final path = appRouter.routerDelegate.currentConfiguration.uri.path;

      final inboxVisible =
          path == '/notificaciones' || path == '/ciudadano/alertas';

      final operations = <Future<void>>[cubit.refreshCount()];

      if (inboxVisible) {
        operations.add(cubit.refresh());
      }

      await Future.wait(operations);
    } finally {
      _refreshing = false;

      if (mounted && _dirty) {
        _scheduleInboxRefresh();
      }
    }
  }

  // ==========================================================
  // CICLO DE VIDA
  // ==========================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      _syncSession(context.read<SessionBloc>().state);

      _socket.ensureConnected();

      if (_socket.waitingForAuthentication) {
        _requestTokenRefresh();
      }

      _scheduleInboxRefresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _authenticationTimer?.cancel();

    _statusSubscription?.cancel();
    _eventsSubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    _socket.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.session?.accessToken != current.session?.accessToken ||
          previous.session?.usuario.idUsuario !=
              current.session?.usuario.idUsuario,
      listener: (_, state) => _syncSession(state),
      child: widget.child,
    );
  }
}
