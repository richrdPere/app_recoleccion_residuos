import 'package:flutter_bloc/flutter_bloc.dart';

// Use Cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/tracking/tracking_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/blocs/tracking/tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingUseCases trackingUseCases;

  TrackingBloc(this.trackingUseCases) : super(const TrackingState()) {
    on<TrackingEvent>(
      _onTrackingEvent,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  Future<void> _onTrackingEvent(
    TrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (event is TrackingUbicacionRegistrada) {
      await _registrarUbicacion(event, emit);
    } else if (event is TrackingUbicacionesLoteRegistradas) {
      await _registrarUbicacionesLote(event, emit);
    }
  }

  // ==========================================================
  // REGISTRAR UBICACIÓN
  // ==========================================================
  Future<void> _registrarUbicacion(
    TrackingUbicacionRegistrada event,
    Emitter<TrackingState> emit,
  ) async {
    emit(
      const TrackingState(
        operacion: TrackingOperacion.registrarUbicacion,
        procesando: true,
      ),
    );

    try {
      final response = await trackingUseCases.registrarUbicacion.run(
        request: event.request,
      );

      emit(
        TrackingState(
          operacion: TrackingOperacion.registrarUbicacion,
          ubicacionResponse: response,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);

      emit(
        const TrackingState(
          operacion: TrackingOperacion.registrarUbicacion,
          errorInesperado:
              'Ocurrió un error inesperado al registrar la ubicación.',
        ),
      );
    }
  }

  // ==========================================================
  // REGISTRAR UBICACIONES POR LOTE
  // ==========================================================
  Future<void> _registrarUbicacionesLote(
    TrackingUbicacionesLoteRegistradas event,
    Emitter<TrackingState> emit,
  ) async {
    emit(
      const TrackingState(
        operacion: TrackingOperacion.registrarUbicacionesLote,
        procesando: true,
      ),
    );

    try {
      final response = await trackingUseCases.registrarUbicacionLote.run(
        request: event.request,
      );

      emit(
        TrackingState(
          operacion: TrackingOperacion.registrarUbicacionesLote,
          ubicacionesLoteResponse: response,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);

      emit(
        const TrackingState(
          operacion: TrackingOperacion.registrarUbicacionesLote,
          errorInesperado:
              'Ocurrió un error inesperado al registrar las ubicaciones.',
        ),
      );
    }
  }
}
