import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum CiudadanoDomiciliosStatus { initial, loading, ready, failure }

enum CiudadanoDomiciliosAction {
  none,
  create,
  update,
  setPrincipal,
  delete,
  changeEstado,
}

enum CiudadanoDomiciliosActionStatus { initial, processing, success, failure }

enum CiudadanoDomicilioCoberturaStatus { initial, loading, ready, failure }

class CiudadanoDomiciliosState {
  final CiudadanoDomiciliosStatus status;
  final List<GetMisDomiciliosDataModel> domicilios;
  final bool incluirInactivos;

  final CiudadanoDomiciliosAction action;
  final CiudadanoDomiciliosActionStatus actionStatus;

  // Domicilio sobre el que se está ejecutando la operación.
  final int? idDomicilioProcesando;

  // Domicilio confirmado por la última operación exitosa.
  final int? idDomicilioResultado;

  final String? errorMessage;
  final int? statusCode;

  final String? actionErrorMessage;
  final int? actionStatusCode;

  final String? successMessage;

  // Aumenta una vez por cada modificación confirmada.
  final int cambiosConfirmados;

  // COBERTURA
  final CiudadanoDomicilioCoberturaStatus coberturaStatus;

  final ResolverCoberturaRequest? coberturaRequest;
  final ResolverCoberturaDataModel? cobertura;

  final String? coberturaErrorMessage;
  final int? coberturaStatusCode;

  const CiudadanoDomiciliosState({
    this.status = CiudadanoDomiciliosStatus.initial,
    this.domicilios = const [],
    this.incluirInactivos = false,
    this.action = CiudadanoDomiciliosAction.none,
    this.actionStatus = CiudadanoDomiciliosActionStatus.initial,
    this.idDomicilioProcesando,
    this.idDomicilioResultado,
    this.errorMessage,
    this.statusCode,
    this.actionErrorMessage,
    this.actionStatusCode,
    this.successMessage,
    this.cambiosConfirmados = 0,
    this.coberturaStatus = CiudadanoDomicilioCoberturaStatus.initial,
    this.coberturaRequest,
    this.cobertura,
    this.coberturaErrorMessage,
    this.coberturaStatusCode,
  });

  bool get isLoading => status == CiudadanoDomiciliosStatus.loading;

  bool get isProcessing =>
      actionStatus == CiudadanoDomiciliosActionStatus.processing;

  // Conservamos su significado original.
  // La cobertura tiene su propio indicador.
  bool get isBusy => isLoading || isProcessing;

  bool get isEmpty =>
      status == CiudadanoDomiciliosStatus.ready && domicilios.isEmpty;

  bool get isActionSuccess =>
      actionStatus == CiudadanoDomiciliosActionStatus.success;

  bool get isActionFailure =>
      actionStatus == CiudadanoDomiciliosActionStatus.failure;

  bool get isResolviendoCobertura =>
      coberturaStatus == CiudadanoDomicilioCoberturaStatus.loading;

  bool get isCoberturaReady =>
      coberturaStatus == CiudadanoDomicilioCoberturaStatus.ready;

  bool get isCoberturaFailure =>
      coberturaStatus == CiudadanoDomicilioCoberturaStatus.failure;

  bool get tieneCobertura =>
      isCoberturaReady && cobertura?.tieneCobertura == true;

  bool isProcessingDomicilio(int idDomicilio) {
    return isProcessing && idDomicilioProcesando == idDomicilio;
  }

  CiudadanoDomiciliosState copyWith({
    CiudadanoDomiciliosStatus? status,
    List<GetMisDomiciliosDataModel>? domicilios,
    bool? incluirInactivos,
    CiudadanoDomiciliosAction? action,
    CiudadanoDomiciliosActionStatus? actionStatus,
    int? idDomicilioProcesando,
    int? idDomicilioResultado,
    String? errorMessage,
    int? statusCode,
    String? actionErrorMessage,
    int? actionStatusCode,
    String? successMessage,
    int? cambiosConfirmados,
    bool clearListError = false,
    bool clearActionResult = false,
    bool clearProcessingId = false,

    // Cobertura
    CiudadanoDomicilioCoberturaStatus? coberturaStatus,
    ResolverCoberturaRequest? coberturaRequest,
    ResolverCoberturaDataModel? cobertura,
    String? coberturaErrorMessage,
    int? coberturaStatusCode,
    bool clearCobertura = false,
    bool clearCoberturaRequest = false,
    bool clearCoberturaError = false,
  }) {
    return CiudadanoDomiciliosState(
      status: status ?? this.status,
      domicilios: domicilios ?? this.domicilios,
      incluirInactivos: incluirInactivos ?? this.incluirInactivos,
      action: action ?? this.action,
      actionStatus: actionStatus ?? this.actionStatus,

      idDomicilioProcesando: clearProcessingId
          ? null
          : idDomicilioProcesando ?? this.idDomicilioProcesando,

      idDomicilioResultado: clearActionResult
          ? null
          : idDomicilioResultado ?? this.idDomicilioResultado,

      errorMessage: clearListError ? null : errorMessage ?? this.errorMessage,

      statusCode: clearListError ? null : statusCode ?? this.statusCode,

      actionErrorMessage: clearActionResult
          ? null
          : actionErrorMessage ?? this.actionErrorMessage,

      actionStatusCode: clearActionResult
          ? null
          : actionStatusCode ?? this.actionStatusCode,

      successMessage: clearActionResult
          ? null
          : successMessage ?? this.successMessage,

      cambiosConfirmados: cambiosConfirmados ?? this.cambiosConfirmados,

      coberturaStatus: coberturaStatus ?? this.coberturaStatus,

      coberturaRequest: clearCoberturaRequest
          ? null
          : coberturaRequest ?? this.coberturaRequest,

      cobertura: clearCobertura ? null : cobertura ?? this.cobertura,

      coberturaErrorMessage: clearCoberturaError
          ? null
          : coberturaErrorMessage ?? this.coberturaErrorMessage,

      coberturaStatusCode: clearCoberturaError
          ? null
          : coberturaStatusCode ?? this.coberturaStatusCode,
    );
  }
}
