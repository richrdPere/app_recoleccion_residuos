import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

import 'ciudadano_domicilios_event.dart';
import 'ciudadano_domicilios_state.dart';

class CiudadanoDomiciliosBloc
    extends Bloc<CiudadanoDomiciliosEvent, CiudadanoDomiciliosState> {
  final DomiciliosUseCases domiciliosUseCases;

  int _operationId = 0;

  CiudadanoDomiciliosBloc(this.domiciliosUseCases)
    : super(const CiudadanoDomiciliosState()) {
    on<CiudadanoDomiciliosRequested>(_onRequested);
    on<CiudadanoDomicilioCreateSubmitted>(_onCreate);
    on<CiudadanoDomicilioUpdateSubmitted>(_onUpdate);
    on<CiudadanoDomicilioPrincipalSubmitted>(_onSetPrincipal);
    on<CiudadanoDomicilioDeleteSubmitted>(_onDelete);
    on<CiudadanoDomiciliosReset>(_onReset);
  }

  // *********************************************************
  // 1. LIMPIAR ESTADO
  // *********************************************************

  void _onReset(
    CiudadanoDomiciliosReset event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) {
    _operationId++;

    emit(const CiudadanoDomiciliosState());
  }

  // *********************************************************
  // 2. CONSULTAR LISTADO
  // *********************************************************

  Future<void> _onRequested(
    CiudadanoDomiciliosRequested event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) async {
    if (state.isBusy) return;

    final operationId = ++_operationId;

    emit(
      state.copyWith(
        status: CiudadanoDomiciliosStatus.loading,
        incluirInactivos: event.incluirInactivos,
        action: CiudadanoDomiciliosAction.none,
        actionStatus: CiudadanoDomiciliosActionStatus.initial,
        clearListError: true,
        clearActionResult: true,
        clearProcessingId: true,
      ),
    );

    await _fetchDomicilios(emit, operationId: operationId);
  }

  // *********************************************************
  // 3. CREAR
  // *********************************************************

  Future<void> _onCreate(
    CiudadanoDomicilioCreateSubmitted event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) async {
    await _executeAction<CreateCiudadanoDomicilioDataModel>(
      emit,
      action: CiudadanoDomiciliosAction.create,
      execute: () {
        return domiciliosUseCases.createCiudadanoDomicilio.run(
          request: event.request,
        );
      },
      resultId: (data) => data.idDomicilio,
    );
  }

  // *********************************************************
  // 4. ACTUALIZAR
  // *********************************************************

  Future<void> _onUpdate(
    CiudadanoDomicilioUpdateSubmitted event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) async {
    await _executeAction<UpdateCiudadanoDomicilioDataModel>(
      emit,
      action: CiudadanoDomiciliosAction.update,
      idDomicilio: event.idDomicilio,
      execute: () {
        return domiciliosUseCases.updateCiudadanoDomicilio.run(
          idDomicilio: event.idDomicilio,
          request: event.request,
        );
      },
      resultId: (data) => data.idDomicilio,
    );
  }

  // *********************************************************
  // 5. ESTABLECER PRINCIPAL
  // *********************************************************

  Future<void> _onSetPrincipal(
    CiudadanoDomicilioPrincipalSubmitted event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) async {
    await _executeAction<SetPrincipalCiudadanoDomicilioDataModel>(
      emit,
      action: CiudadanoDomiciliosAction.setPrincipal,
      idDomicilio: event.idDomicilio,
      execute: () {
        return domiciliosUseCases.setPrincipalCiudadanoDomicilio.run(
          idDomicilio: event.idDomicilio,
        );
      },
      resultId: (data) => data.idDomicilio,
      validateResult: (data) => data.esPrincipal,
    );
  }

  // *********************************************************
  // 6. ELIMINAR
  // *********************************************************

  Future<void> _onDelete(
    CiudadanoDomicilioDeleteSubmitted event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) async {
    await _executeAction<DeleteCiudadanoDomicilioDataModel>(
      emit,
      action: CiudadanoDomiciliosAction.delete,
      idDomicilio: event.idDomicilio,
      execute: () {
        return domiciliosUseCases.deleteCiudadanoDomicilio.run(
          idDomicilio: event.idDomicilio,
        );
      },
      resultId: (data) => data.idDomicilio,
      validateResult: (data) => data.eliminado,
    );
  }

  // *********************************************************
  // 7. EJECUTAR MODIFICACIÓN Y RECARGAR
  // *********************************************************

  Future<void> _executeAction<T>(
    Emitter<CiudadanoDomiciliosState> emit, {
    required CiudadanoDomiciliosAction action,
    required Future<Resource<ApiResponse<T>>> Function() execute,
    required int Function(T data) resultId,
    bool Function(T data)? validateResult,
    int? idDomicilio,
  }) async {
    if (state.isBusy) return;

    final operationId = ++_operationId;

    emit(
      state.copyWith(
        action: action,
        actionStatus: CiudadanoDomiciliosActionStatus.processing,
        idDomicilioProcesando: idDomicilio,
        clearProcessingId: idDomicilio == null,
        clearListError: true,
        clearActionResult: true,
      ),
    );

    if (idDomicilio != null && idDomicilio <= 0) {
      _emitActionFailure(
        emit,
        message: 'El identificador del domicilio no es válido.',
        statusCode: 400,
      );
      return;
    }

    try {
      final resource = await execute();

      if (!_isCurrent(emit, operationId)) return;

      if (resource is ErrorData<ApiResponse<T>>) {
        _emitActionFailure(
          emit,
          message: resource.message,
          statusCode: resource.statusCode,
        );
        return;
      }

      if (resource is! Success<ApiResponse<T>>) {
        _emitActionFailure(
          emit,
          message: 'No se recibió un resultado válido de la operación.',
        );
        return;
      }

      final api = resource.data;
      final data = api.data;

      if (!api.success || data == null) {
        _emitActionFailure(
          emit,
          message:
              'El servidor no confirmó la operación. '
              'Consulta tus domicilios antes de repetirla.',
        );
        return;
      }

      final confirmedId = resultId(data);

      if (confirmedId <= 0 ||
          (idDomicilio != null && confirmedId != idDomicilio) ||
          (validateResult != null && !validateResult(data))) {
        _emitActionFailure(
          emit,
          message:
              'La respuesta no confirmó el cambio solicitado. '
              'Consulta tus domicilios para verificarlo.',
        );
        return;
      }

      // Confirmación de la modificación.
      // Mantener processing hasta terminar la recarga.
      emit(
        state.copyWith(
          idDomicilioResultado: confirmedId,
          successMessage: api.message,
          cambiosConfirmados: state.cambiosConfirmados + 1,
        ),
      );

      await _fetchDomicilios(
        emit,
        operationId: operationId,
        afterMutation: true,
      );
    } catch (_) {
      if (!_isCurrent(emit, operationId)) return;

      _emitActionFailure(
        emit,
        message:
            'No se pudo confirmar la operación. '
            'Consulta tus domicilios antes de repetirla.',
      );
    }
  }

  // *********************************************************
  // 8. CONSULTA COMPARTIDA DEL LISTADO
  // *********************************************************

  Future<void> _fetchDomicilios(
    Emitter<CiudadanoDomiciliosState> emit, {
    required int operationId,
    bool afterMutation = false,
  }) async {
    try {
      final resource = await domiciliosUseCases.getMisDomicilios.run(
        incluirInactivos: state.incluirInactivos,
      );

      if (!_isCurrent(emit, operationId)) return;

      if (resource is ErrorData<ApiResponse<List<GetMisDomiciliosDataModel>>>) {
        _emitListFailure(
          emit,
          message: afterMutation
              ? 'El cambio fue confirmado, pero no se pudo '
                    'actualizar el listado. Vuelve a consultarlo.'
              : resource.message,
          statusCode: resource.statusCode,
          afterMutation: afterMutation,
        );
        return;
      }

      if (resource is! Success<ApiResponse<List<GetMisDomiciliosDataModel>>>) {
        throw const FormatException('Respuesta de domicilios inválida.');
      }

      final api = resource.data;
      final data = api.data;

      if (!api.success || data == null) {
        throw const FormatException('No se recibió la lista de domicilios.');
      }

      emit(
        state.copyWith(
          status: CiudadanoDomiciliosStatus.ready,
          domicilios: List<GetMisDomiciliosDataModel>.unmodifiable(data),
          actionStatus: afterMutation
              ? CiudadanoDomiciliosActionStatus.success
              : CiudadanoDomiciliosActionStatus.initial,
          clearListError: true,
          clearProcessingId: true,
        ),
      );
    } catch (_) {
      if (!_isCurrent(emit, operationId)) return;

      _emitListFailure(
        emit,
        message: afterMutation
            ? 'El cambio fue confirmado, pero no se pudo '
                  'actualizar el listado. Vuelve a consultarlo.'
            : 'No se pudieron consultar tus domicilios.',
        afterMutation: afterMutation,
      );
    }
  }

  // *********************************************************
  // 9. ERRORES
  // *********************************************************

  void _emitActionFailure(
    Emitter<CiudadanoDomiciliosState> emit, {
    required String message,
    int? statusCode,
  }) {
    emit(
      state.copyWith(
        actionStatus: CiudadanoDomiciliosActionStatus.failure,
        actionErrorMessage: message,
        actionStatusCode: statusCode,
        clearProcessingId: true,
      ),
    );
  }

  void _emitListFailure(
    Emitter<CiudadanoDomiciliosState> emit, {
    required String message,
    required bool afterMutation,
    int? statusCode,
  }) {
    emit(
      state.copyWith(
        status: CiudadanoDomiciliosStatus.failure,
        errorMessage: message,
        statusCode: statusCode,

        // La modificación sí se confirmó, aunque falle el GET.
        actionStatus: afterMutation
            ? CiudadanoDomiciliosActionStatus.success
            : CiudadanoDomiciliosActionStatus.initial,
        clearProcessingId: true,
      ),
    );
  }

  // *********************************************************
  // 10. DESCARTAR RESPUESTAS DE UNA SESIÓN ANTERIOR
  // *********************************************************

  bool _isCurrent(Emitter<CiudadanoDomiciliosState> emit, int operationId) {
    return !emit.isDone && operationId == _operationId;
  }
}
