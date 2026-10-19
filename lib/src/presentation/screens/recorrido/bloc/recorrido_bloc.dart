import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Use cases
import 'package:app_recoleccion_residuos/src/domain/use_cases/recorrido/RecorridoUseCases.dart';

// Bloc
import 'recorrido_event.dart';
import 'recorrido_state.dart';

class RecorridoBloc extends Bloc<RecorridoEvent, RecorridoState> {
  final RecorridoUsecases recorridoUsecases;

  RecorridoBloc(this.recorridoUsecases) : super(RecorridoState.initial()) {
    // Un único registro permite ordenar consultas y acciones entre sí.
    on<RecorridoEvent>(
      _onEvent,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  Future<void> _onEvent(
    RecorridoEvent event,
    Emitter<RecorridoState> emit,
  ) async {
    if (event is ObtenerRecorridoActivo) {
      await _obtenerActivo(emit);
    } else if (event is ObtenerMisRecorridos) {
      await _obtenerHistorial(event, emit);
    } else if (event is ObtenerRecorridoDetalle) {
      await _obtenerDetalle(event, emit);
    } else if (event is IniciarRecorrido) {
      await _ejecutarAccion(
        emit,
        accion: RecorridoAccion.iniciar,
        ejecutar: () => recorridoUsecases.iniciarRecorrido.run(
          idProgramacion: event.idProgramacion,
          request: event.request,
        ),
      );
    } else if (event is PausarRecorrido) {
      await _ejecutarAccion(
        emit,
        accion: RecorridoAccion.pausar,
        ejecutar: () => recorridoUsecases.pausarRecorrido.run(
          idRecorrido: event.idRecorrido,
          request: event.request,
        ),
      );
    } else if (event is ReanudarRecorrido) {
      await _ejecutarAccion(
        emit,
        accion: RecorridoAccion.reanudar,
        ejecutar: () => recorridoUsecases.reanudarRecorrido.run(
          idRecorrido: event.idRecorrido,
          request: event.request,
        ),
      );
    } else if (event is FinalizarRecorrido) {
      await _ejecutarAccion(
        emit,
        accion: RecorridoAccion.finalizar,
        ejecutar: () => recorridoUsecases.finalizarRecorrido.run(
          idRecorrido: event.idRecorrido,
          request: event.request,
        ),
      );
    } else if (event is LimpiarResultadoAccion) {
      emit(state.copyWith(accion: null, accionResponse: null));
    }
  }

  /// Normaliza excepciones y respuestas Success con success == false.
  Future<Resource<ApiResponse<T>>> _solicitar<T>(
    Future<Resource<ApiResponse<T>>> Function() ejecutar, {
    required String mensajeError,
    bool permitirDataNull = false,
  }) async {
    try {
      final response = await ejecutar();

      if (response is Success<ApiResponse<T>>) {
        final api = response.data;

        if (!api.success) {
          return ErrorData<ApiResponse<T>>(
            message: api.message.isEmpty ? mensajeError : api.message,
            error: api.error,
          );
        }

        if (!permitirDataNull && api.data == null) {
          return ErrorData<ApiResponse<T>>(
            message: 'El servidor no devolvió los datos esperados.',
          );
        }

        return response;
      }

      if (response is ErrorData<ApiResponse<T>>) {
        return response;
      }

      return ErrorData<ApiResponse<T>>(
        message: 'La operación no devolvió un resultado válido.',
      );
    } catch (error) {
      return ErrorData<ApiResponse<T>>(
        message: mensajeError,
        error: error.toString(),
      );
    }
  }

  Future<void> _obtenerActivo(Emitter<RecorridoState> emit) async {
    emit(
      state.copyWith(
        activoResponse: Loading<ApiResponse<RecorridoDataModel?>>(),
      ),
    );

    final response = await _solicitar<RecorridoDataModel?>(
      () => recorridoUsecases.getRecorridoActivo.run(),
      mensajeError: 'No se pudo consultar el recorrido activo.',
      permitirDataNull: true,
    );

    debugPrint("========================================================");
    debugPrint("RES BLOC: $response");
    debugPrint("========================================================");

    if (emit.isDone) return;

    if (response is Success<ApiResponse<RecorridoDataModel?>>) {
      // null representa una consulta exitosa sin recorrido activo.
      emit(
        state.copyWith(
          activoResponse: response,
          recorridoActivo: response.data.data,
        ),
      );
    } else {
      // Conserva el último recorrido conocido ante un error.
      emit(state.copyWith(activoResponse: response));
    }
  }

  Future<void> _obtenerDetalle(
    ObtenerRecorridoDetalle event,
    Emitter<RecorridoState> emit,
  ) async {
    final mismoDetalle =
        state.recorridoDetalle?.idRecorrido == event.idRecorrido;

    emit(
      state.copyWith(
        idDetalleSolicitado: event.idRecorrido,
        recorridoDetalle: mismoDetalle ? state.recorridoDetalle : null,
        detalleResponse: Loading<ApiResponse<RecorridoDataModel?>>(),
      ),
    );

    final response = await _solicitar<RecorridoDataModel?>(
      () => recorridoUsecases.getRecorridoById.run(
        idRecorrido: event.idRecorrido,
      ),
      mensajeError: 'No se pudo consultar el detalle del recorrido.',
    );

    if (emit.isDone) return;

    if (response is Success<ApiResponse<RecorridoDataModel?>>) {
      emit(
        state.copyWith(
          detalleResponse: response,
          recorridoDetalle: response.data.data,
        ),
      );
    } else {
      emit(state.copyWith(detalleResponse: response));
    }
  }

  Future<void> _obtenerHistorial(
    ObtenerMisRecorridos event,
    Emitter<RecorridoState> emit,
  ) async {
    if (event.page < 1 || event.limit < 1) {
      emit(
        state.copyWith(
          historialResponse: ErrorData<ApiResponse<MisRecorridosDataModel>>(
            message: 'La página y el límite deben ser mayores que cero.',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        historialResponse: Loading<ApiResponse<MisRecorridosDataModel>>(),
      ),
    );

    final response = await _solicitar<MisRecorridosDataModel>(
      () => recorridoUsecases.getMisRecorridos.run(
        page: event.page,
        limit: event.limit,
      ),
      mensajeError: 'No se pudo consultar el historial de recorridos.',
    );

    if (emit.isDone) return;

    if (response is Success<ApiResponse<MisRecorridosDataModel>>) {
      emit(
        state.copyWith(
          historialResponse: response,
          historial: response.data.data,
          page: event.page,
          limit: event.limit,
        ),
      );
    } else {
      emit(state.copyWith(historialResponse: response));
    }
  }

  Future<void> _ejecutarAccion(
    Emitter<RecorridoState> emit, {
    required RecorridoAccion accion,
    required Future<Resource<ApiResponse<RecorridoDataModel>>> Function()
    ejecutar,
  }) async {
    emit(
      state.copyWith(
        accion: accion,
        accionResponse: Loading<ApiResponse<RecorridoDataModel>>(),
      ),
    );

    final response = await _solicitar<RecorridoDataModel>(
      ejecutar,
      mensajeError: 'No se pudo completar la acción del recorrido.',
    );

    if (emit.isDone) return;

    if (response is! Success<ApiResponse<RecorridoDataModel>>) {
      emit(state.copyWith(accionResponse: response));
      return;
    }

    final recorrido = response.data.data!;

    final actualizarDetalle =
        state.idDetalleSolicitado == recorrido.idRecorrido;

    final finalizar = accion == RecorridoAccion.finalizar;

    // No borra un activo diferente al recorrido finalizado.
    final borrarActivo =
        finalizar &&
        state.recorridoActivo?.idRecorrido == recorrido.idRecorrido;

    emit(
      state.copyWith(
        accionResponse: response,
        recorridoActivo: finalizar
            ? (borrarActivo ? null : state.recorridoActivo)
            : recorrido,
        recorridoDetalle: actualizarDetalle
            ? recorrido
            : state.recorridoDetalle,
        // Los resultados de consulta anteriores dejan de representar
        // la versión actual del recorrido después de una acción.
        activoResponse: null,
        detalleResponse: actualizarDetalle ? null : state.detalleResponse,
      ),
    );

    // Consulta el estado autoritativo después de finalizar.
    if (finalizar) {
      await _obtenerActivo(emit);
    }

    // Actualiza la página del historial si ya había sido cargada.
    if (!emit.isDone && state.historial != null) {
      await _obtenerHistorial(
        ObtenerMisRecorridos(page: state.page, limit: state.limit),
        emit,
      );
    }
  }
}
