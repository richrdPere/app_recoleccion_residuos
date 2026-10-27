import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Use Cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/programacion/bloc/programaciones_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/programacion/bloc/programaciones_state.dart';

class ProgramacionesBloc
    extends Bloc<ProgramacionesEvent, ProgramacionesState> {
  final ProgramacionesUseCases programacionesUseCases;

  ProgramacionesBloc(this.programacionesUseCases)
    : super(ProgramacionesState.initial()) {
    on<ObtenerMisAsignaciones>(
      _onObtenerMisAsignaciones,
      transformer: restartable(),
    );

    on<ObtenerProgramacionDetalle>(
      _onObtenerProgramacionDetalle,
      transformer: restartable(),
    );

    on<ResponderAsignacion>(_onResponderAsignacion, transformer: droppable());
  }

  // *********************************************************
  // 1. OBTENER MIS ASIGNACIONES
  // *********************************************************

  Future<void> _onObtenerMisAsignaciones(
    ObtenerMisAsignaciones event,
    Emitter<ProgramacionesState> emit,
  ) async {
    emit(
      state.copyWith(
        misAsignaciones: Loading<ApiResponse<MisAsignacionesDataModel>>(),
      ),
    );

    try {
      final resultado = await programacionesUseCases.getMisAsignaciones.run(
        filters: event.filters,
      );

      if (emit.isDone) return;

      emit(state.copyWith(misAsignaciones: resultado));
    } catch (_) {
      if (emit.isDone) return;

      emit(
        state.copyWith(
          misAsignaciones: ErrorData<ApiResponse<MisAsignacionesDataModel>>(
            message:
                'Ocurrió un error inesperado '
                'al obtener tus asignaciones.',
          ),
        ),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER DETALLE DE PROGRAMACIÓN
  // *********************************************************

  Future<void> _onObtenerProgramacionDetalle(
    ObtenerProgramacionDetalle event,
    Emitter<ProgramacionesState> emit,
  ) async {
    if (event.idProgramacion <= 0) {
      emit(
        state.copyWith(
          idProgramacionDetalle: event.idProgramacion,
          programacionDetalle:
              ErrorData<ApiResponse<ProgramacionDetalleDataModel>>(
                message: 'El identificador de programación no es válido.',
              ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        idProgramacionDetalle: event.idProgramacion,
        programacionDetalle:
            Loading<ApiResponse<ProgramacionDetalleDataModel>>(),
      ),
    );

    try {
      final resultado = await programacionesUseCases.getProgramacionDetalle.run(
        idProgramacion: event.idProgramacion,
      );

      if (emit.isDone) return;

      emit(state.copyWith(programacionDetalle: resultado));
    } catch (_) {
      if (emit.isDone) return;

      emit(
        state.copyWith(
          programacionDetalle:
              ErrorData<ApiResponse<ProgramacionDetalleDataModel>>(
                message:
                    'Ocurrió un error inesperado '
                    'al obtener el detalle de la programación.',
              ),
        ),
      );
    }
  }

  // *********************************************************
  // 3. RESPONDER ASIGNACIÓN
  // *********************************************************

  Future<void> _onResponderAsignacion(
    ResponderAsignacion event,
    Emitter<ProgramacionesState> emit,
  ) async {
    if (event.idProgramacionPersonal <= 0) {
      emit(
        state.copyWith(
          idProgramacionPersonalRespuesta: event.idProgramacionPersonal,
          respuestaAsignacion:
              ErrorData<ApiResponse<ResponderAsignacionDataModel>>(
                message: 'El identificador de asignación no es válido.',
              ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        idProgramacionPersonalRespuesta: event.idProgramacionPersonal,
        respuestaAsignacion:
            Loading<ApiResponse<ResponderAsignacionDataModel>>(),
      ),
    );

    try {
      final resultado = await programacionesUseCases.responderAsignacion.run(
        idProgramacionPersonal: event.idProgramacionPersonal,
        request: event.request,
      );

      if (emit.isDone) return;

      emit(state.copyWith(respuestaAsignacion: resultado));
    } catch (_) {
      if (emit.isDone) return;

      emit(
        state.copyWith(
          respuestaAsignacion:
              ErrorData<ApiResponse<ResponderAsignacionDataModel>>(
                message:
                    'Ocurrió un error inesperado '
                    'al responder la asignación.',
              ),
        ),
      );
    }
  }
}
