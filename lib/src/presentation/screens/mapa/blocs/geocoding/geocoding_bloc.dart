import 'package:flutter_bloc/flutter_bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Use Cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/geocoding/geocoding_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/geocoding/geocoding_state.dart';

class GeocodingBloc extends Bloc<GeocodingEvent, GeocodingState> {
  final GeocodingUseCases geocodingUseCases;

  /// Control independiente para cada tipo de operación.
  int _solicitudBusqueda = 0;
  int _solicitudDireccion = 0;

  GeocodingBloc(this.geocodingUseCases) : super(GeocodingState.initial()) {
    on<BuscarDireccionGeocoding>(_onBuscarDireccion);
    on<ObtenerDireccionGeocoding>(_onObtenerDireccion);
    on<LimpiarGeocoding>(_onLimpiar);
  }

  // *********************************************************
  // 1. BUSCAR DIRECCIÓN POR TEXTO
  // *********************************************************

  Future<void> _onBuscarDireccion(
    BuscarDireccionGeocoding event,
    Emitter<GeocodingState> emit,
  ) async {
    final solicitud = ++_solicitudBusqueda;
    final texto = event.texto.trim();

    // Al vaciar el texto, se limpia la búsqueda y se invalidan
    // los resultados de cualquier búsqueda anterior pendiente.
    if (texto.isEmpty) {
      emit(
        state.copyWith(busqueda: Initial<List<DireccionGeograficaEntity>>()),
      );
      return;
    }

    emit(state.copyWith(busqueda: Loading<List<DireccionGeograficaEntity>>()));

    try {
      final resultado = await geocodingUseCases.buscarDireccion.run(
        texto: texto,
        proximidad: event.proximidad,
        limites: event.limites,
        codigoPais: event.codigoPais,
        limite: event.limite,
      );

      if (emit.isDone || solicitud != _solicitudBusqueda) {
        return;
      }

      emit(state.copyWith(busqueda: resultado));
    } catch (_) {
      if (emit.isDone || solicitud != _solicitudBusqueda) {
        return;
      }

      emit(
        state.copyWith(
          busqueda: ErrorData<List<DireccionGeograficaEntity>>(
            message:
                'Ocurrió un error inesperado '
                'al buscar la dirección.',
          ),
        ),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER DIRECCIÓN POR COORDENADAS
  // *********************************************************

  Future<void> _onObtenerDireccion(
    ObtenerDireccionGeocoding event,
    Emitter<GeocodingState> emit,
  ) async {
    final solicitud = ++_solicitudDireccion;

    emit(state.copyWith(direccion: Loading<List<DireccionGeograficaEntity>>()));

    try {
      final resultado = await geocodingUseCases.obtenerDireccion.run(
        coordenada: event.coordenada,
      );

      if (emit.isDone || solicitud != _solicitudDireccion) {
        return;
      }

      emit(state.copyWith(direccion: resultado));
    } catch (_) {
      if (emit.isDone || solicitud != _solicitudDireccion) {
        return;
      }

      emit(
        state.copyWith(
          direccion: ErrorData<List<DireccionGeograficaEntity>>(
            message:
                'Ocurrió un error inesperado '
                'al consultar la dirección del punto.',
          ),
        ),
      );
    }
  }

  // *********************************************************
  // 3. LIMPIAR RESULTADOS
  // *********************************************************

  void _onLimpiar(LimpiarGeocoding event, Emitter<GeocodingState> emit) {
    // Impide que respuestas pendientes repongan los resultados.
    _solicitudBusqueda++;
    _solicitudDireccion++;

    emit(GeocodingState.initial());
  }
}
