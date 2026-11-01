// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// ============================================================
// CALLBACKS
// ============================================================

typedef FcmTokenChanged = Future<void> Function(String token);

typedef FcmMessageReceived = Future<void> Function(RemoteMessage message);

typedef FcmMessageOpened = Future<void> Function(RemoteMessage message);

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ==========================================================
  // SUBSCRIPTIONS
  // ==========================================================

  StreamSubscription<String>? _tokenSubscription;

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  // ==========================================================
  // ESTADO
  // ==========================================================

  String? _currentToken;

  bool _initialized = false;
  bool _initialMessageProcessed = false;

  String? get currentToken => _currentToken;

  bool get isInitialized => _initialized;

  Stream<RemoteMessage> get onMessage {
    return FirebaseMessaging.onMessage;
  }

  // ==========================================================
  // INICIALIZAR
  // ==========================================================

  Future<void> initialize({
    required FcmTokenChanged onTokenChanged,
    FcmMessageReceived? onForegroundMessage,
    FcmMessageOpened? onMessageOpened,
  }) async {
    await _requestPermission();

    /*
     * Evita que iOS muestre automáticamente la notificación
     * foreground si nosotros utilizaremos una notificación local.
     *
     * En Android, los mensajes foreground tampoco se muestran
     * automáticamente.
     */
    await _configureForegroundPresentation();

    /*
     * El registro inicial debe completarse correctamente.
     * Si el backend rechaza el token, el error se propaga al
     * AuthListener para que pueda volver a intentarlo.
     */
    await _registerInitialToken(onTokenChanged);

    _listenTokenRefresh(onTokenChanged);

    if (onForegroundMessage != null) {
      listenForegroundMessages(onMessageReceived: onForegroundMessage);
    }

    if (onMessageOpened != null) {
      listenMessageOpenedApp(onMessageOpened: onMessageOpened);
    }

    _initialized = true;
  }

  // ==========================================================
  // PERMISOS
  // ==========================================================

  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint('Permiso FCM: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('El usuario rechazó las notificaciones.');
    }

    return settings;
  }

  // ==========================================================
  // PRESENTACIÓN FOREGROUND
  // ==========================================================

  Future<void> _configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      /*
       * Se configuran en false porque la notificación visual
       * foreground será mostrada mediante
       * flutter_local_notifications.
       */
      alert: false,
      badge: false,
      sound: false,
    );
  }

  // ==========================================================
  // TOKEN INICIAL
  // ==========================================================

  Future<void> _registerInitialToken(FcmTokenChanged onTokenChanged) async {
    final token = await _messaging.getToken();

    if (token == null || token.trim().isEmpty) {
      throw StateError('Firebase Messaging no devolvió un token FCM.');
    }

    _currentToken = token.trim();

    debugPrint('Token FCM inicial obtenido correctamente.');

    /*
     * El callback registra el token en tu backend.
     *
     * No se atrapa aquí el error intencionalmente. Si el backend
     * falla, initialize() también debe fallar para que el
     * AuthListener no marque el registro como exitoso.
     */
    await onTokenChanged(_currentToken!);
  }

  // ==========================================================
  // RENOVACIÓN DEL TOKEN
  // ==========================================================

  void _listenTokenRefresh(FcmTokenChanged onTokenChanged) {
    unawaited(_tokenSubscription?.cancel());

    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (token) async {
        final normalizedToken = token.trim();

        if (normalizedToken.isEmpty) {
          return;
        }

        _currentToken = normalizedToken;

        debugPrint('Token FCM renovado correctamente.');

        try {
          await onTokenChanged(normalizedToken);
        } catch (error, stackTrace) {
          debugPrint(
            'Error registrando token FCM renovado: '
            '$error\n$stackTrace',
          );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Error escuchando renovación FCM: '
          '$error\n$stackTrace',
        );
      },
    );
  }

  // ==========================================================
  // PRIMER PLANO
  // ==========================================================

  void listenForegroundMessages({
    required FcmMessageReceived onMessageReceived,
  }) {
    unawaited(_foregroundMessageSubscription?.cancel());

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      (message) async {
        debugPrint('FCM foreground: ${message.messageId}');

        debugPrint('FCM foreground data: ${message.data}');

        try {
          await onMessageReceived(message);
        } catch (error, stackTrace) {
          debugPrint(
            'Error procesando mensaje foreground: '
            '$error\n$stackTrace',
          );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Error escuchando mensajes foreground: '
          '$error\n$stackTrace',
        );
      },
    );
  }

  // ==========================================================
  // ABRIR DESDE SEGUNDO PLANO
  // ==========================================================

  void listenMessageOpenedApp({required FcmMessageOpened onMessageOpened}) {
    unawaited(_messageOpenedSubscription?.cancel());

    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        debugPrint(
          'FCM abierto desde background: '
          '${message.messageId}',
        );

        try {
          await onMessageOpened(message);
        } catch (error, stackTrace) {
          debugPrint(
            'Error procesando apertura de notificación: '
            '$error\n$stackTrace',
          );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Error escuchando onMessageOpenedApp: '
          '$error\n$stackTrace',
        );
      },
    );
  }

  // ==========================================================
  // ABRIR DESDE APP CERRADA
  // ==========================================================

  Future<void> processInitialMessage({
    required FcmMessageOpened onMessageOpened,
  }) async {
    if (_initialMessageProcessed) {
      return;
    }

    final message = await _messaging.getInitialMessage();

    /*
     * Firebase entrega este mensaje una sola vez.
     */
    _initialMessageProcessed = true;

    if (message == null) {
      return;
    }

    debugPrint(
      'FCM abrió la aplicación cerrada: '
      '${message.messageId}',
    );

    debugPrint('FCM initial data: ${message.data}');

    await onMessageOpened(message);
  }

  /// Se conserva para uso manual cuando sea necesario.
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  // ==========================================================
  // OBTENER TOKEN
  // ==========================================================

  Future<String?> refreshToken() async {
    final token = await _messaging.getToken();

    final normalizedToken = token?.trim();

    if (normalizedToken == null || normalizedToken.isEmpty) {
      return null;
    }

    _currentToken = normalizedToken;

    return _currentToken;
  }

  // ==========================================================
  // ELIMINAR TOKEN
  // ==========================================================

  Future<void> deleteToken() async {
    await _messaging.deleteToken();

    _currentToken = null;
  }

  // ==========================================================
  // CANCELAR LISTENERS
  // ==========================================================

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();

    _tokenSubscription = null;
    _foregroundMessageSubscription = null;
    _messageOpenedSubscription = null;

    _initialized = false;

    /*
     * No reiniciamos _initialMessageProcessed.
     *
     * El mensaje inicial de una apertura debe consumirse una sola
     * vez durante toda la ejecución de la aplicación.
     */
  }
}
