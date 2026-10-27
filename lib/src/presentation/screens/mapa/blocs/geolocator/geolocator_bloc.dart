import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Use Cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/geolocator/geolocator_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/geolocator/geolocator_state.dart';

class GeolocatorBloc extends Bloc<GeolocatorEvent, GeolocatorState> {
  final GeolocatorUseCases geolocatorUseCases;

  GeolocatorBloc(this.geolocatorUseCases) : super(GeolocatorState.initial()) {
    on<ServicioGeolocatorEvent>(_onServicio, transformer: restartable());

    // Evita solicitar permisos simultáneamente.
    on<PermisoGeolocatorEvent>(_onPermiso, transformer: sequential());

    on<ObtenerUbicacionActualGeolocator>(
      _onObtenerUbicacionActual,
      transformer: restartable(),
    );

    on<ObtenerUltimaUbicacionGeolocator>(
      _onObtenerUltimaUbicacion,
      transformer: restartable(),
    );

    on<SeguimientoGeolocatorEvent>(_onSeguimiento, transformer: restartable());

    on<ConfiguracionGeolocatorEvent>(
      _onAbrirConfiguracion,
      transformer: sequential(),
    );
  }

  // *********************************************************
  // 1. VERIFICAR / OBSERVAR / DEJAR DE OBSERVAR SERVICIO
  // *********************************************************
  Future<void> _onServicio(
    ServicioGeolocatorEvent event,
    Emitter<GeolocatorState> emit,
  ) async {
    if (event is DetenerObservacionServicioGeolocator) {
      emit(
        state.copyWith(
          observandoServicio: false,
          servicio: state.servicio is Loading<bool>
              ? Initial<bool>()
              : state.servicio,
        ),
      );
      return;
    }

    final observar = event is ObservarServicioGeolocator;

    emit(state.copyWith(observandoServicio: observar));

    await _resolver<bool>(
      emit: emit,
      operacion: () => geolocatorUseCases.estaServicioHabilitado.run(),
      actualizar: (resultado) => state.copyWith(servicio: resultado),
      mensajeError: 'No se pudo verificar el servicio de ubicación.',
    );

    if (emit.isDone || !observar) {
      return;
    }

    try {
      await emit.forEach<bool>(
        geolocatorUseCases.observarEstadoServicio.run(),
        onData: (habilitado) {
          return state.copyWith(servicio: Success<bool>(habilitado));
        },
      );
    } catch (_) {
      if (!emit.isDone) {
        emit(
          state.copyWith(
            servicio: ErrorData<bool>(
              message:
                  'No se pudo observar el estado '
                  'del servicio de ubicación.',
            ),
          ),
        );
      }
    }

    if (!emit.isDone) {
      emit(state.copyWith(observandoServicio: false));
    }
  }

  // *********************************************************
  // 2. VERIFICAR / SOLICITAR PERMISO
  // *********************************************************

  Future<void> _onPermiso(
    PermisoGeolocatorEvent event,
    Emitter<GeolocatorState> emit,
  ) async {
    await _resolver<PermisoUbicacion>(
      emit: emit,
      operacion: () {
        if (event is SolicitarPermisoGeolocator) {
          return geolocatorUseCases.solicitarPermiso.run();
        }

        return geolocatorUseCases.verificarPermiso.run();
      },
      actualizar: (resultado) => state.copyWith(permiso: resultado),
      mensajeError:
          'No se pudo consultar o solicitar '
          'el permiso de ubicación.',
    );
  }

  // *********************************************************
  // 3. OBTENER UBICACIÓN ACTUAL
  // *********************************************************

  Future<void> _onObtenerUbicacionActual(
    ObtenerUbicacionActualGeolocator event,
    Emitter<GeolocatorState> emit,
  ) async {
    await _resolver<UbicacionEntity>(
      emit: emit,
      operacion: () => geolocatorUseCases.obtenerUbicacionActual.run(
        tiempoLimite: event.tiempoLimite,
      ),
      actualizar: (resultado) => state.copyWith(ubicacionActual: resultado),
      mensajeError: 'No se pudo obtener la ubicación actual.',
    );
  }

  // *********************************************************
  // 4. OBTENER ÚLTIMA UBICACIÓN
  // *********************************************************

  Future<void> _onObtenerUltimaUbicacion(
    ObtenerUltimaUbicacionGeolocator event,
    Emitter<GeolocatorState> emit,
  ) async {
    await _resolver<UbicacionEntity?>(
      emit: emit,
      operacion: () => geolocatorUseCases.obtenerUltimaUbicacion.run(),
      actualizar: (resultado) => state.copyWith(ultimaUbicacion: resultado),
      mensajeError: 'No se pudo obtener la última ubicación.',
    );
  }

  // *********************************************************
  // 5. INICIAR / DETENER SEGUIMIENTO
  // *********************************************************

  Future<void> _onSeguimiento(
    SeguimientoGeolocatorEvent event,
    Emitter<GeolocatorState> emit,
  ) async {
    if (event is DetenerSeguimientoGeolocator) {
      emit(
        state.copyWith(
          siguiendoUbicacion: false,
          seguimiento: Initial<UbicacionEntity>(),
        ),
      );
      return;
    }

    if (event is! IniciarSeguimientoGeolocator) {
      return;
    }

    emit(
      state.copyWith(
        siguiendoUbicacion: true,
        seguimiento: Loading<UbicacionEntity>(),
      ),
    );

    try {
      await emit.forEach<Resource<UbicacionEntity>>(
        geolocatorUseCases.observarUbicacion.run(
          configuracion: event.configuracion,
        ),
        onData: (resultado) {
          return state.copyWith(seguimiento: resultado);
        },
      );
    } catch (_) {
      if (!emit.isDone) {
        emit(
          state.copyWith(
            seguimiento: ErrorData<UbicacionEntity>(
              message: 'Se interrumpió la escucha de ubicación.',
            ),
          ),
        );
      }
    }

    if (!emit.isDone) {
      emit(state.copyWith(siguiendoUbicacion: false));
    }
  }

  // *********************************************************
  // 6. ABRIR CONFIGURACIÓN
  // *********************************************************

  Future<void> _onAbrirConfiguracion(
    ConfiguracionGeolocatorEvent event,
    Emitter<GeolocatorState> emit,
  ) async {
    if (event is AbrirConfiguracionAplicacionGeolocator) {
      await _resolver<bool>(
        emit: emit,
        operacion: () => geolocatorUseCases.abrirConfiguracionAplicacion.run(),
        actualizar: (resultado) =>
            state.copyWith(aperturaConfiguracionAplicacion: resultado),
        mensajeError:
            'No se pudo abrir la configuración '
            'de la aplicación.',
      );
      return;
    }

    await _resolver<bool>(
      emit: emit,
      operacion: () => geolocatorUseCases.abrirConfiguracionUbicacion.run(),
      actualizar: (resultado) =>
          state.copyWith(aperturaConfiguracionUbicacion: resultado),
      mensajeError:
          'No se pudo abrir la configuración '
          'de ubicación.',
    );
  }

  // *********************************************************
  // EJECUTAR OPERACIÓN CON RESOURCE
  // *********************************************************

  Future<void> _resolver<T>({
    required Emitter<GeolocatorState> emit,
    required Future<Resource<T>> Function() operacion,
    required GeolocatorState Function(Resource<T>) actualizar,
    required String mensajeError,
  }) async {
    emit(actualizar(Loading<T>()));

    try {
      final resultado = await operacion();

      if (!emit.isDone) {
        emit(actualizar(resultado));
      }
    } catch (_) {
      if (!emit.isDone) {
        emit(actualizar(ErrorData<T>(message: mensajeError)));
      }
    }
  }
}
