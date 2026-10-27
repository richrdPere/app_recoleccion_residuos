import 'package:flutter_bloc/flutter_bloc.dart';

// Uses cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'mapa_event.dart';
import 'mapa_state.dart';

class MapaBloc extends Bloc<MapaEvent, MapaState> {
  final MapaUsesCase mapaUsesCase;

  MapaBloc(this.mapaUsesCase) : super(const MapaInicial()) {
    on<MapaInicializado>(_onMapaInicializado);
  }

  void _onMapaInicializado(MapaInicializado event, Emitter<MapaState> emit) {
    emit(const MapaConfiguracionCargando());

    try {
      final configuracion = mapaUsesCase.getConfiguracionInicial.run();

      emit(MapaConfiguracionDisponible(configuracion: configuracion));
    } catch (error, stackTrace) {
      addError(error, stackTrace);

      emit(
        const MapaConfiguracionError(
          mensaje: 'No se pudo obtener la configuración del mapa.',
        ),
      );
    }
  }
}
