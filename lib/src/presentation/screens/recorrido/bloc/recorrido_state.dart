import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

enum RecorridoAccion { iniciar, pausar, reanudar, finalizar }

class RecorridoState {
  static const Object _sinCambio = Object();

  final RecorridoDataModel? recorridoActivo;
  final RecorridoDataModel? recorridoDetalle;

  /// Una página del historial, tal como la devuelve el backend.
  final MisRecorridosDataModel? historial;

  final Resource<ApiResponse<RecorridoDataModel?>>? activoResponse;
  final Resource<ApiResponse<RecorridoDataModel?>>? detalleResponse;
  final Resource<ApiResponse<MisRecorridosDataModel>>? historialResponse;
  final Resource<ApiResponse<RecorridoDataModel>>? accionResponse;

  final RecorridoAccion? accion;

  /// Identifica el detalle solicitado, incluso si la consulta falla.
  final int? idDetalleSolicitado;

  /// Página y límite de la última consulta exitosa.
  final int page;
  final int limit;

  const RecorridoState({
    this.recorridoActivo,
    this.recorridoDetalle,
    this.historial,
    this.activoResponse,
    this.detalleResponse,
    this.historialResponse,
    this.accionResponse,
    this.accion,
    this.idDetalleSolicitado,
    this.page = 1,
    this.limit = 10,
  });

  factory RecorridoState.initial() => const RecorridoState();

  bool get isLoadingActivo =>
      activoResponse is Loading<ApiResponse<RecorridoDataModel?>>;

  bool get isLoadingDetalle =>
      detalleResponse is Loading<ApiResponse<RecorridoDataModel?>>;

  bool get isLoadingHistorial =>
      historialResponse is Loading<ApiResponse<MisRecorridosDataModel>>;

  bool get isProcessingAccion =>
      accionResponse is Loading<ApiResponse<RecorridoDataModel>>;

  bool get tieneRecorridoActivo => recorridoActivo != null;

  RecorridoState copyWith({
    Object? recorridoActivo = _sinCambio,
    Object? recorridoDetalle = _sinCambio,
    Object? historial = _sinCambio,
    Object? activoResponse = _sinCambio,
    Object? detalleResponse = _sinCambio,
    Object? historialResponse = _sinCambio,
    Object? accionResponse = _sinCambio,
    Object? accion = _sinCambio,
    Object? idDetalleSolicitado = _sinCambio,
    int? page,
    int? limit,
  }) {
    return RecorridoState(
      recorridoActivo: identical(recorridoActivo, _sinCambio)
          ? this.recorridoActivo
          : recorridoActivo as RecorridoDataModel?,
      recorridoDetalle: identical(recorridoDetalle, _sinCambio)
          ? this.recorridoDetalle
          : recorridoDetalle as RecorridoDataModel?,
      historial: identical(historial, _sinCambio)
          ? this.historial
          : historial as MisRecorridosDataModel?,
      activoResponse: identical(activoResponse, _sinCambio)
          ? this.activoResponse
          : activoResponse as Resource<ApiResponse<RecorridoDataModel?>>?,
      detalleResponse: identical(detalleResponse, _sinCambio)
          ? this.detalleResponse
          : detalleResponse as Resource<ApiResponse<RecorridoDataModel?>>?,
      historialResponse: identical(historialResponse, _sinCambio)
          ? this.historialResponse
          : historialResponse as Resource<ApiResponse<MisRecorridosDataModel>>?,
      accionResponse: identical(accionResponse, _sinCambio)
          ? this.accionResponse
          : accionResponse as Resource<ApiResponse<RecorridoDataModel>>?,
      accion: identical(accion, _sinCambio)
          ? this.accion
          : accion as RecorridoAccion?,
      idDetalleSolicitado: identical(idDetalleSolicitado, _sinCambio)
          ? this.idDetalleSolicitado
          : idDetalleSolicitado as int?,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
