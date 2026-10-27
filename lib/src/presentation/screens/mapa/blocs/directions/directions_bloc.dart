import 'package:flutter_bloc/flutter_bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Use Cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/directions/directions_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/directions/directions_state.dart';

class DirectionsBloc extends Bloc<DirectionsEvent, DirectionsState> {
  final DirectionsUseCases directionsUseCases;

  /// Permite descartar respuestas de solicitudes anteriores.
  int _solicitudActual = 0;

  DirectionsBloc(this.directionsUseCases) : super(DirectionsState.initial()) {
    on<CalcularRutaDirections>(_onCalcularRuta);
    on<LimpiarRutaDirections>(_onLimpiarRuta);
  }

  // *********************************************************
  // 1. CALCULAR RUTA
  // *********************************************************

  Future<void> _onCalcularRuta(
    CalcularRutaDirections event,
    Emitter<DirectionsState> emit,
  ) async {
    final solicitud = ++_solicitudActual;

    emit(DirectionsState(resultado: Loading<RutaCalculadaEntity>()));

    try {
      final resultado = await directionsUseCases.calcularRuta.run(
        origen: event.origen,
        destino: event.destino,
        puntosIntermedios: event.puntosIntermedios,
        perfil: event.perfil,
        incluirInstrucciones: event.incluirInstrucciones,
      );

      if (emit.isDone || solicitud != _solicitudActual) {
        return;
      }

      emit(DirectionsState(resultado: resultado));
    } catch (_) {
      if (emit.isDone || solicitud != _solicitudActual) {
        return;
      }

      emit(
        DirectionsState(
          resultado: ErrorData<RutaCalculadaEntity>(
            message: 'Ocurrió un error inesperado al calcular la ruta.',
          ),
        ),
      );
    }
  }

  // *********************************************************
  // 2. LIMPIAR RUTA
  // *********************************************************

  void _onLimpiarRuta(
    LimpiarRutaDirections event,
    Emitter<DirectionsState> emit,
  ) {
    // Invalida cualquier cálculo que todavía esté pendiente.
    _solicitudActual++;

    emit(DirectionsState.initial());
  }
}
