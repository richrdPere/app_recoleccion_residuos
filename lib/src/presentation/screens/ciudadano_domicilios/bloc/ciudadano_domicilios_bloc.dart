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
  int _coberturaId = 0;

  CiudadanoDomiciliosBloc(this.domiciliosUseCases)
    : super(const CiudadanoDomiciliosState()) {
    on<CiudadanoDomiciliosRequested>(_onRequested);
    on<CiudadanoDomicilioCreateSubmitted>(_onCreate);
    on<CiudadanoDomicilioUpdateSubmitted>(_onUpdate);
    on<CiudadanoDomicilioPrincipalSubmitted>(_onSetPrincipal);
    on<CiudadanoDomicilioDeleteSubmitted>(_onDelete);
    on<CiudadanoDomiciliosReset>(_onReset);

    on<CiudadanoDomicilioCoberturaRequested>(_onResolverCobertura);
    on<CiudadanoDomicilioCoberturaReset>(_onCoberturaReset);
    on<CiudadanoDomicilioEstadoSubmitted>(_onChangeEstado);
  }

  // *********************************************************
  // 1. LIMPIAR ESTADO
  // *********************************************************

  void _onReset(
    CiudadanoDomiciliosReset event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) {
    _operationId++;
    _coberturaId++;

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
  // *********************************************************
  // 11. RESOLVER COBERTURA
  // *********************************************************

  Future<void> _onResolverCobertura(
    CiudadanoDomicilioCoberturaRequested event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) async {
    final coberturaId = ++_coberturaId;
    final request = event.request;

    // Invalida el resultado anterior desde el inicio.
    // No modifica el listado ni el resultado de las acciones.
    emit(
      state.copyWith(
        coberturaStatus: CiudadanoDomicilioCoberturaStatus.loading,
        coberturaRequest: request,
        clearCobertura: true,
        clearCoberturaError: true,
      ),
    );

    if (!request.latitud.isFinite ||
        !request.longitud.isFinite ||
        request.latitud < -90 ||
        request.latitud > 90 ||
        request.longitud < -180 ||
        request.longitud > 180) {
      _emitCoberturaFailure(
        emit,
        message: 'Selecciona una ubicación válida para el domicilio.',
        statusCode: 400,
      );
      return;
    }

    try {
      final resource = await domiciliosUseCases.resolverCobertura.run(
        request: request,
      );

      if (!_isCurrentCobertura(emit, coberturaId)) return;

      if (resource is ErrorData<ApiResponse<ResolverCoberturaDataModel>>) {
        _emitCoberturaFailure(
          emit,
          message: resource.message,
          statusCode: resource.statusCode,
        );
        return;
      }

      if (resource is! Success<ApiResponse<ResolverCoberturaDataModel>>) {
        _emitCoberturaFailure(
          emit,
          message: 'No se recibió un resultado válido de cobertura.',
        );
        return;
      }

      final api = resource.data;
      final data = api.data;

      if (!api.success || data == null) {
        _emitCoberturaFailure(
          emit,
          message: 'El servidor no confirmó la consulta de cobertura.',
        );
        return;
      }

      // Verifica que el resultado corresponda al punto solicitado.
      const tolerance = 0.0000001;

      if (!data.latitud.isFinite ||
          !data.longitud.isFinite ||
          (data.latitud - request.latitud).abs() > tolerance ||
          (data.longitud - request.longitud).abs() > tolerance) {
        _emitCoberturaFailure(
          emit,
          message:
              'La cobertura recibida no corresponde a la ubicación '
              'seleccionada. Vuelve a consultar.',
        );
        return;
      }

      // Sin cobertura también es una consulta exitosa.
      emit(
        state.copyWith(
          coberturaStatus: CiudadanoDomicilioCoberturaStatus.ready,
          cobertura: data,
          clearCoberturaError: true,
        ),
      );
    } catch (_) {
      if (!_isCurrentCobertura(emit, coberturaId)) return;

      _emitCoberturaFailure(
        emit,
        message:
            'No se pudo consultar la cobertura. '
            'Intenta nuevamente.',
      );
    }
  }

  // *********************************************************
  // 12. LIMPIAR SOLO LA COBERTURA
  // *********************************************************

  void _onCoberturaReset(
    CiudadanoDomicilioCoberturaReset event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) {
    // Ignorar cualquier respuesta pendiente del formulario anterior.
    _coberturaId++;

    emit(
      state.copyWith(
        coberturaStatus: CiudadanoDomicilioCoberturaStatus.initial,
        clearCobertura: true,
        clearCoberturaRequest: true,
        clearCoberturaError: true,
      ),
    );
  }

  // *********************************************************
  // 13. ERROR DE COBERTURA
  // *********************************************************

  void _emitCoberturaFailure(
    Emitter<CiudadanoDomiciliosState> emit, {
    required String message,
    int? statusCode,
  }) {
    emit(
      state
          .copyWith(
            coberturaStatus: CiudadanoDomicilioCoberturaStatus.failure,
            coberturaErrorMessage: message,
            coberturaStatusCode: statusCode,
            clearCobertura: true,

            // Permite limpiar un código de error anterior.
            clearCoberturaError: true,
          )
          .copyWith(
            coberturaErrorMessage: message,
            coberturaStatusCode: statusCode,
          ),
    );
  }

  // *********************************************************
  // 14. DESCARTAR COBERTURAS ANTERIORES
  // *********************************************************

  bool _isCurrentCobertura(
    Emitter<CiudadanoDomiciliosState> emit,
    int coberturaId,
  ) {
    return !emit.isDone && coberturaId == _coberturaId;
  }

  // *********************************************************
  // 15. CAMBIAR ESTADO Y RECARGAR LISTADO
  // *********************************************************

  Future<void> _onChangeEstado(
    CiudadanoDomicilioEstadoSubmitted event,
    Emitter<CiudadanoDomiciliosState> emit,
  ) async {
    await _executeAction<UpdateCiudadanoDomicilioDataModel>(
      emit,
      action: CiudadanoDomiciliosAction.changeEstado,
      idDomicilio: event.idDomicilio,
      execute: () {
        return domiciliosUseCases.changeEstadoCiudadanoDomicilio.run(
          idDomicilio: event.idDomicilio,
          activo: event.activo,
        );
      },
      resultId: (data) => data.idDomicilio,
      validateResult: (data) {
        final esperado = event.activo ? 'ACTIVO' : 'INACTIVO';

        return data.estadoDomicilio == esperado;
      },
    );
  }
}
