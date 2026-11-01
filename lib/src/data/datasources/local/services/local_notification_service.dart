import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  LocalNotificationsService._();

  static final instance = LocalNotificationsService._();

  static const channelId = 'recoleccion_alertas';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _taps = StreamController<String>.broadcast();

  Future<void>? _initialization;

  String? _initialPayload;

  Stream<String> get onTap => _taps.stream;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload != null && payload.isNotEmpty) {
          _taps.add(payload);
        }
      },
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        'Alertas de recolección',
        description: 'Asignaciones y avisos del servicio de recolección.',
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Apertura de la app desde una notificación LOCAL.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      _initialPayload = launchDetails?.notificationResponse?.payload;
    }
  }

  String? takeInitialPayload() {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  Future<void> show({
    required int idNotificacionUsuario,
    required String userId,
    required String title,
    required String body,
  }) async {
    await initialize();

    await _plugin.show(
      // Android utiliza identificadores enteros de 32 bits.
      idNotificacionUsuario & 0x7fffffff,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Alertas de recolección',
          channelDescription:
              'Asignaciones y avisos del servicio de recolección.',
          icon: 'ic_notification',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
          autoCancel: true,
          onlyAlertOnce: true,
          tag: 'notificacion-usuario:$idNotificacionUsuario',
        ),
      ),
      payload: jsonEncode({
        'id_notificacion_usuario': idNotificacionUsuario,
        'id_usuario': userId,
      }),
    );
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
