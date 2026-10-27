import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

typedef MostrarMensajeUbicacion =
    void Function(String mensaje, {VoidCallback? accion});

enum _PasoUbicacion { inactivo, servicio, permiso, posicion }

class MapaUbicacionController extends ChangeNotifier
    with WidgetsBindingObserver {
  final GeolocatorBloc geolocatorBloc;
  final MostrarMensajeUbicacion onMensaje;
  final ValueChanged<UbicacionEntity> onUbicacionObtenida;

  late final StreamSubscription<GeolocatorState> _suscripcion;
  late GeolocatorState _estadoAnterior;

  _PasoUbicacion _paso = _PasoUbicacion.inactivo;

  bool _permisoSolicitado = false;
  bool _esperandoRetornoConfiguracion = false;
  bool _disposed = false;

  MapaUbicacionController({
    required this.geolocatorBloc,
    required this.onMensaje,
    required this.onUbicacionObtenida,
  }) {
    _estadoAnterior = geolocatorBloc.state;

    _suscripcion = geolocatorBloc.stream.listen(
      _procesarEstado,
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;

        _finalizar();

        onMensaje('Ocurrió un error al consultar la ubicación.');
      },
    );

    WidgetsBinding.instance.addObserver(this);
  }

  bool get ubicacionPendiente => _paso != _PasoUbicacion.inactivo;

  // *********************************************************
  // 1. SOLICITAR MI UBICACIÓN
  // *********************************************************

  void solicitarUbicacion() {
    if (_disposed || ubicacionPendiente) return;

    if (geolocatorBloc.isClosed) {
      onMensaje('El módulo de ubicación no está disponible.');
      return;
    }

    _permisoSolicitado = false;
    _cambiarPaso(_PasoUbicacion.permiso);
    // _cambiarPaso(_PasoUbicacion.servicio);

    geolocatorBloc.add(const VerificarPermisoGeolocator());
  }

  // *********************************************************
  // 2. PROCESAR ESTADOS DEL BLOC
  // *********************************************************

  void _procesarEstado(GeolocatorState state) {
    if (_disposed) return;

    final anterior = _estadoAnterior;
    _estadoAnterior = state;

    if (_esperandoRetornoConfiguracion) {
      if (anterior.aperturaConfiguracionAplicacion !=
          state.aperturaConfiguracionAplicacion) {
        _revisarApertura(state.aperturaConfiguracionAplicacion);
      }

      if (anterior.aperturaConfiguracionUbicacion !=
          state.aperturaConfiguracionUbicacion) {
        _revisarApertura(state.aperturaConfiguracionUbicacion);
      }
    }

    switch (_paso) {
      case _PasoUbicacion.servicio:
        if (anterior.servicio != state.servicio) {
          _procesarServicio(state.servicio);
        }
        return;

      case _PasoUbicacion.permiso:
        if (anterior.permiso != state.permiso) {
          _procesarPermiso(state.permiso);
        }
        return;

      case _PasoUbicacion.posicion:
        if (anterior.ubicacionActual != state.ubicacionActual) {
          _procesarPosicion(state.ubicacionActual);
        }
        return;

      case _PasoUbicacion.inactivo:
        return;
    }
  }

  // *********************************************************
  // 3. VERIFICAR SERVICIO
  // *********************************************************

  void _procesarServicio(Resource<bool> recurso) {
  if (recurso is ErrorData<bool>) {
    _finalizar();
    onMensaje(recurso.fullMessage);
    return;
  }

  if (recurso is! Success<bool>) return;

  if (!recurso.data) {
    _finalizar();

    onMensaje(
      'El permiso está concedido, pero la ubicación '
      'del dispositivo está desactivada.',
      accion: abrirConfiguracionUbicacion,
    );
    return;
  }

  _cambiarPaso(_PasoUbicacion.posicion);

  geolocatorBloc.add(
    const ObtenerUbicacionActualGeolocator(),
  );
}

  // *********************************************************
  // 4. VERIFICAR / SOLICITAR PERMISO
  // *********************************************************

  void _procesarPermiso(Resource<PermisoUbicacion> recurso) {
    if (recurso is ErrorData<PermisoUbicacion>) {
      _finalizar();
      onMensaje(recurso.fullMessage);
      return;
    }

    if (recurso is! Success<PermisoUbicacion>) return;

    final permiso = recurso.data;

    switch (permiso) {
      case PermisoUbicacion.duranteUso:
      case PermisoUbicacion.siempre:
        _cambiarPaso(_PasoUbicacion.servicio);

        geolocatorBloc.add(const VerificarServicioGeolocator());
        return;

      case PermisoUbicacion.denegado:
        if (!_permisoSolicitado) {
          _permisoSolicitado = true;

          geolocatorBloc.add(const SolicitarPermisoGeolocator());
        } else {
          _finalizar();

          onMensaje('No se concedió el permiso de ubicación.');
        }
        return;

      case PermisoUbicacion.denegadoPermanentemente:
        _finalizar();

        onMensaje(
          'El permiso está bloqueado. Habilítalo desde '
          'la configuración de la aplicación.',
          accion: abrirConfiguracionAplicacion,
        );
        return;

      case PermisoUbicacion.desconocido:
        _finalizar();

        onMensaje('No se pudo determinar el permiso de ubicación.');
        return;
    }
  }

  // *********************************************************
  // 5. RECIBIR POSICIÓN
  // *********************************************************

  void _procesarPosicion(Resource<UbicacionEntity> recurso) {
    if (recurso is ErrorData<UbicacionEntity>) {
      _finalizar();
      onMensaje(recurso.fullMessage);
      return;
    }

    if (recurso is! Success<UbicacionEntity>) return;

    _finalizar();

    onUbicacionObtenida(recurso.data);
  }

  // *********************************************************
  // 6. ABRIR CONFIGURACIÓN
  // *********************************************************

  void abrirConfiguracionAplicacion() {
    if (_disposed || ubicacionPendiente) return;

    _esperandoRetornoConfiguracion = true;

    geolocatorBloc.add(const AbrirConfiguracionAplicacionGeolocator());
  }

  void abrirConfiguracionUbicacion() {
    if (_disposed || ubicacionPendiente) return;

    _esperandoRetornoConfiguracion = true;

    geolocatorBloc.add(const AbrirConfiguracionUbicacionGeolocator());
  }

  void _revisarApertura(Resource<bool> recurso) {
    if (recurso is ErrorData<bool>) {
      _esperandoRetornoConfiguracion = false;
      onMensaje(recurso.fullMessage);
    } else if (recurso is Success<bool> && !recurso.data) {
      _esperandoRetornoConfiguracion = false;

      onMensaje('No se pudo abrir la configuración del dispositivo.');
    }
  }

  // *********************************************************
  // 7. REGRESAR DESDE CONFIGURACIÓN
  // *********************************************************

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed ||
        state != AppLifecycleState.resumed ||
        !_esperandoRetornoConfiguracion) {
      return;
    }

    _esperandoRetornoConfiguracion = false;

    // Vuelve a comprobar GPS y permiso antes de obtener posición.
    solicitarUbicacion();
  }

  // *********************************************************
  // ESTADO INTERNO Y LIMPIEZA
  // *********************************************************

  void _cambiarPaso(_PasoUbicacion paso) {
    if (_disposed) return;

    _paso = paso;
    notifyListeners();
  }

  void _finalizar() {
    _cambiarPaso(_PasoUbicacion.inactivo);
  }

  @override
  void dispose() {
    _disposed = true;

    WidgetsBinding.instance.removeObserver(this);
    unawaited(_suscripcion.cancel());

    super.dispose();
  }
}
