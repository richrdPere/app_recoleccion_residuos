import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class GeolocatorService {
  // *********************************************************
  // 1. VERIFICAR SERVICIO DE UBICACIÓN
  // *********************************************************
  Future<Resource<bool>> estaServicioHabilitado() {
    return _ejecutar<bool>(() => geo.Geolocator.isLocationServiceEnabled());
  }

  // *********************************************************
  // 2. OBSERVAR ESTADO DEL SERVICIO DE UBICACIÓN
  // *********************************************************
  Stream<bool> observarEstadoServicio() {
    return geo.Geolocator.getServiceStatusStream()
        .map((estado) => estado == geo.ServiceStatus.enabled)
        .distinct();
  }

  // *********************************************************
  // 3. VERIFICAR PERMISO
  // *********************************************************
  Future<Resource<PermisoUbicacion>> verificarPermiso() {
    return _ejecutar<PermisoUbicacion>(() async {
      final permiso = await geo.Geolocator.checkPermission();

      return _convertirPermiso(permiso);
    });
  }

  // *********************************************************
  // 4. SOLICITAR PERMISO
  // *********************************************************
  Future<Resource<PermisoUbicacion>> solicitarPermiso() {
    return _ejecutar<PermisoUbicacion>(() async {
      final permiso = await geo.Geolocator.requestPermission();

      return _convertirPermiso(permiso);
    });
  }

  // *********************************************************
  // 5. OBTENER UBICACIÓN ACTUAL
  // *********************************************************
  Future<Resource<UbicacionEntity>> obtenerUbicacionActual({
    Duration tiempoLimite = const Duration(seconds: 20),
  }) {
    return _ejecutar<UbicacionEntity>(() async {
      if (tiempoLimite <= Duration.zero) {
        throw const _UbicacionException(
          'El tiempo límite debe ser mayor que cero.',
        );
      }

      await _comprobarAcceso();

      final posicion = await geo.Geolocator.getCurrentPosition(
        locationSettings: geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: tiempoLimite,
        ),
      );

      return _convertirPosicion(posicion);
    });
  }

  // *********************************************************
  // 6. OBTENER ÚLTIMA UBICACIÓN CONOCIDA
  // *********************************************************
  Future<Resource<UbicacionEntity?>> obtenerUltimaUbicacion() {
    return _ejecutar<UbicacionEntity?>(() async {
      await _comprobarPermiso();

      final posicion = await geo.Geolocator.getLastKnownPosition();

      if (posicion == null) {
        return null;
      }

      return _convertirPosicion(posicion);
    });
  }

  // *********************************************************
  // 7. OBSERVAR UBICACIÓN
  // *********************************************************
  Stream<Resource<UbicacionEntity>> observarUbicacion({
    required ConfiguracionUbicacionEntity configuracion,
  }) async* {
    try {
      _validarConfiguracion(configuracion);

      await _comprobarAcceso();

      final posiciones = geo.Geolocator.getPositionStream(
        locationSettings: _crearAjustes(configuracion),
      );

      await for (final posicion in posiciones) {
        yield Success<UbicacionEntity>(_convertirPosicion(posicion));
      }
    } catch (e) {
      yield ErrorData<UbicacionEntity>(message: _mensajeError(e));
    }
  }

  // *********************************************************
  // 8. ABRIR CONFIGURACIÓN DE LA APLICACIÓN
  // *********************************************************
  Future<Resource<bool>> abrirConfiguracionAplicacion() {
    return _ejecutar<bool>(() => geo.Geolocator.openAppSettings());
  }

  // *********************************************************
  // 9. ABRIR CONFIGURACIÓN DE UBICACIÓN
  // *********************************************************
  Future<Resource<bool>> abrirConfiguracionUbicacion() {
    return _ejecutar<bool>(() => geo.Geolocator.openLocationSettings());
  }

  // *********************************************************
  // EJECUTAR OPERACIÓN Y MANEJAR ERRORES
  // *********************************************************
  Future<Resource<T>> _ejecutar<T>(Future<T> Function() operacion) async {
    try {
      final resultado = await operacion();

      return Success<T>(resultado);
    } catch (e) {
      return ErrorData<T>(message: _mensajeError(e));
    }
  }

  // *********************************************************
  // COMPROBAR SERVICIO Y PERMISO
  // *********************************************************
  Future<void> _comprobarAcceso() async {
    final habilitado = await geo.Geolocator.isLocationServiceEnabled();

    if (!habilitado) {
      throw const _UbicacionException(
        'Activa el servicio de ubicación del dispositivo.',
      );
    }

    await _comprobarPermiso();
  }

  Future<void> _comprobarPermiso() async {
    final permiso = await geo.Geolocator.checkPermission();

    switch (permiso) {
      case geo.LocationPermission.whileInUse:
      case geo.LocationPermission.always:
        return;

      case geo.LocationPermission.denied:
        throw const _UbicacionException(
          'Debes conceder el permiso de ubicación.',
        );

      case geo.LocationPermission.deniedForever:
        throw const _UbicacionException(
          'Habilita el permiso de ubicación desde '
          'la configuración de la aplicación.',
        );

      case geo.LocationPermission.unableToDetermine:
        throw const _UbicacionException(
          'No se pudo determinar el permiso de ubicación.',
        );
    }
  }

  // *********************************************************
  // CREAR AJUSTES DE UBICACIÓN
  // *********************************************************
  geo.LocationSettings _crearAjustes(
    ConfiguracionUbicacionEntity configuracion,
  ) {
    final precision = _convertirPrecision(configuracion.precision);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return geo.AndroidSettings(
        accuracy: precision,
        distanceFilter: configuracion.distanciaMinimaMetros,
        intervalDuration:
            configuracion.intervalo ?? const Duration(seconds: 10),
      );
    }

    return geo.LocationSettings(
      accuracy: precision,
      distanceFilter: configuracion.distanciaMinimaMetros,
    );
  }

  // *********************************************************
  // VALIDAR CONFIGURACIÓN
  // *********************************************************
  void _validarConfiguracion(ConfiguracionUbicacionEntity configuracion) {
    if (configuracion.distanciaMinimaMetros < 0) {
      throw const _UbicacionException(
        'La distancia mínima no puede ser negativa.',
      );
    }

    final intervalo = configuracion.intervalo;

    if (intervalo != null && intervalo <= Duration.zero) {
      throw const _UbicacionException(
        'El intervalo de ubicación debe ser mayor que cero.',
      );
    }
  }

  // *********************************************************
  // CONVERTIR POSICIÓN A ENTITY
  // *********************************************************
  UbicacionEntity _convertirPosicion(geo.Position posicion) {
    if (!posicion.latitude.isFinite ||
        !posicion.longitude.isFinite ||
        posicion.latitude < -90 ||
        posicion.latitude > 90 ||
        posicion.longitude < -180 ||
        posicion.longitude > 180) {
      throw const _UbicacionException(
        'El dispositivo devolvió coordenadas inválidas.',
      );
    }

    return UbicacionEntity(
      coordenada: CoordenadaEntity(
        latitud: posicion.latitude,
        longitud: posicion.longitude,
      ),
      fechaCaptura: posicion.timestamp.toUtc(),
      precisionMetros: _noNegativo(posicion.accuracy),
      altitudMetros: posicion.altitude.isFinite ? posicion.altitude : null,
      precisionAltitudMetros: _noNegativo(posicion.altitudeAccuracy),
      velocidadMetrosPorSegundo: _noNegativo(posicion.speed),
      precisionVelocidadMetrosPorSegundo: _noNegativo(posicion.speedAccuracy),
      rumboGrados: posicion.heading.isFinite && posicion.heading >= 0
          ? posicion.heading % 360
          : null,
      esSimulada: posicion.isMocked,
    );
  }

  double? _noNegativo(double valor) {
    return valor.isFinite && valor >= 0 ? valor : null;
  }

  // *********************************************************
  // CONVERTIR PERMISO A ENUM DEL DOMINIO
  // *********************************************************
  PermisoUbicacion _convertirPermiso(geo.LocationPermission permiso) {
    switch (permiso) {
      case geo.LocationPermission.denied:
        return PermisoUbicacion.denegado;

      case geo.LocationPermission.deniedForever:
        return PermisoUbicacion.denegadoPermanentemente;

      case geo.LocationPermission.whileInUse:
        return PermisoUbicacion.duranteUso;

      case geo.LocationPermission.always:
        return PermisoUbicacion.siempre;

      case geo.LocationPermission.unableToDetermine:
        return PermisoUbicacion.desconocido;
    }
  }

  // *********************************************************
  // CONVERTIR PRECISIÓN
  // *********************************************************
  geo.LocationAccuracy _convertirPrecision(PrecisionUbicacion precision) {
    switch (precision) {
      case PrecisionUbicacion.baja:
        return geo.LocationAccuracy.low;

      case PrecisionUbicacion.media:
        return geo.LocationAccuracy.medium;

      case PrecisionUbicacion.alta:
        return geo.LocationAccuracy.high;

      case PrecisionUbicacion.maxima:
        return geo.LocationAccuracy.best;
    }
  }

  // *********************************************************
  // MENSAJES DE ERROR
  // *********************************************************
  String _mensajeError(Object error) {
    if (error is _UbicacionException) {
      return error.mensaje;
    }

    if (error is TimeoutException) {
      return 'No se obtuvo una ubicación dentro del tiempo límite.';
    }

    if (error is geo.LocationServiceDisabledException) {
      return 'El servicio de ubicación está desactivado.';
    }

    if (error is geo.PermissionDeniedException) {
      return 'No se concedió el permiso de ubicación.';
    }

    if (error is UnsupportedError || error is UnimplementedError) {
      return 'Esta operación de ubicación no está disponible '
          'en la plataforma actual.';
    }

    return 'No se pudo completar la operación de ubicación.';
  }
}

// ==========================================================
// EXCEPCIÓN INTERNA DEL SERVICIO
// ==========================================================

class _UbicacionException implements Exception {
  final String mensaje;

  const _UbicacionException(this.mensaje);
}
