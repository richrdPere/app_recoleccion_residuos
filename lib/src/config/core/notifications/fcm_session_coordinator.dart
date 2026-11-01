import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_recoleccion_residuos/src/data/datasources/remote/firebase/firebase_messaging_service.dart';

// Models
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Uses cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class FcmSessionCoordinator {
  final DispositivosUseCases dispositivosUseCases;

  final FirebaseMessagingService _fcm = FirebaseMessagingService.instance;

  Future<void> _operations = Future<void>.value();
  Future<void> _registrations = Future<void>.value();

  String? _userId;
  String? _lastRegistration;
  int _generation = 0;

  FcmSessionCoordinator(this.dispositivosUseCases);

  // ==========================================================
  // SINCRONIZAR USUARIO AUTENTICADO
  // ==========================================================

  Future<void> syncSession(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _generation++;
      _lastRegistration = null;
    }

    final generation = _generation;

    _operations = _operations
        .then<void>((_) async {
          if (generation != _generation) return;

          if (userId == null) {
            await _fcm.dispose();
            return;
          }

          if (!_fcm.isInitialized) {
            // Limpia posibles suscripciones de una sesión anterior.
            await _fcm.dispose();

            if (!_isCurrent(userId, generation)) return;

            await _fcm.initialize(
              onTokenChanged: (token) =>
                  _registerToken(token, userId, generation),
            );
          } else {
            // También permite recuperar registros fallidos y
            // detectar cambios de permisos desde ajustes.
            final token = await _fcm.refreshToken();

            if (token != null) {
              await _registerToken(token, userId, generation);
            }
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          // Un problema FCM no invalida la sesión del usuario.
          debugPrint('[FCM sesión] No se completó el registro: $error');
        });

    return _operations;
  }

  bool _isCurrent(String userId, int generation) {
    return _userId == userId && _generation == generation;
  }

  // ==========================================================
  // REGISTRO SERIALIZADO DEL TOKEN
  // ==========================================================

  Future<void> _registerToken(String token, String userId, int generation) {
    final operation = _registrations.then<void>((_) async {
      if (!_isCurrent(userId, generation)) return;

      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      final permission = _permissionValue(settings.authorizationStatus);

      if (!_isCurrent(userId, generation)) return;

      final registrationKey = jsonEncode([userId, token, permission]);

      // No repetir un registro ya confirmado en esta sesión.
      if (_lastRegistration == registrationKey) return;

      final deviceId = await _installationId();

      if (!_isCurrent(userId, generation)) return;

      final result = await dispositivosUseCases.registrarDispositivo.run(
        request: RegistrarDispositivoRequest(
          identificadorDispositivo: deviceId,
          tokenPush: token,
          plataforma: 'ANDROID',

          // Tu backend acepta estos metadatos como opcionales.
          // Después podemos completarlos con device_info_plus
          // y package_info_plus.
          nombreDispositivo: '',
          modeloDispositivo: '',
          versionSistema: '',
          versionAplicacion: '',

          permisoNotificaciones: permission,
        ),
      );

      if (result is ErrorData<ApiResponse<RegistrarDispositivoDataModel>>) {
        throw StateError(result.message);
      }

      if (result is! Success<ApiResponse<RegistrarDispositivoDataModel>>) {
        throw StateError(
          'El servidor no confirmó el registro del dispositivo.',
        );
      }

      if (result.data.data == null) {
        throw StateError('El servidor devolvió un registro vacío.');
      }

      if (!_isCurrent(userId, generation)) return;

      _lastRegistration = registrationKey;

      debugPrint('[FCM sesión] Dispositivo registrado. Permiso: $permission');
    });

    // Conserva una cola utilizable aunque una operación falle.
    // El Future original sí comunica el fallo al llamador.
    _registrations = operation.catchError(
      (Object error, StackTrace stackTrace) {},
    );

    return operation;
  }

  // ==========================================================
  // IDENTIFICADOR PERSISTENTE DE ESTA INSTALACIÓN
  // ==========================================================

  Future<String> _installationId() async {
    const key = 'fcm_installation_id_v1';

    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(key);

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));

    final identifier = 'android_${base64UrlEncode(bytes).replaceAll('=', '')}';

    final saved = await preferences.setString(key, identifier);

    if (!saved) {
      throw StateError('No se pudo guardar el identificador del dispositivo.');
    }

    return identifier;
  }

  // ==========================================================
  // EQUIVALENCIA DE PERMISOS
  // ==========================================================

  String _permissionValue(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return 'AUTORIZADO';
      case AuthorizationStatus.denied:
        return 'DENEGADO';
      case AuthorizationStatus.notDetermined:
        return 'NO_SOLICITADO';
      case AuthorizationStatus.provisional:
        return 'PROVISIONAL';
      case AuthorizationStatus.deniedPermanently:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // ==========================================================
  // EJECUTAR ANTES DEL LOGOUT REMOTO
  // ==========================================================

  Future<void> beforeLogout() async {
    // Invalida callbacks anteriores y detiene las suscripciones.
    await syncSession(null);

    // Espera peticiones que ya habían comenzado.
    await _registrations;

    final token = _fcm.currentToken;

    if (token == null || token.isEmpty) return;

    // Todavía tenemos la sesión y el JWT en el repositorio.
    final result = await dispositivosUseCases.desactivarDispositivoPorToken.run(
      request: DesactivarDispositivoTokenRequest(tokenPush: token),
    );

    if (result is ErrorData<ApiResponse<DesactivarDispositivoTokenDataModel>>) {
      throw StateError(result.message);
    }

    if (result is! Success<ApiResponse<DesactivarDispositivoTokenDataModel>>) {
      throw StateError(
        'El servidor no confirmó la desactivación del dispositivo.',
      );
    }

    final data = result.data.data;

    if (data == null || (!data.desactivado && !data.yaEstabaDesactivado)) {
      throw StateError('No se confirmó la desactivación del dispositivo.');
    }

    debugPrint('[FCM sesión] Dispositivo desactivado.');
  }
}
