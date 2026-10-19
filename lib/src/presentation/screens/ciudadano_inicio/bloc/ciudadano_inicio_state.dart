import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum CiudadanoInicioStatus { initial, loading, ready, failure }

enum CiudadanoInicioCronogramaStatus { initial, loading, ready, failure }

class CiudadanoInicioState {
  final CiudadanoInicioStatus status;

  final List<GetMisDomiciliosDataModel> domicilios;
  final int? idDomicilioSeleccionado;

  final CiudadanoInicioCronogramaStatus cronogramaStatus;
  final GetDomicilioCronogramaDataModel? cronograma;

  final String? errorMessage;
  final int? statusCode;

  final String? cronogramaErrorMessage;
  final int? cronogramaStatusCode;

  const CiudadanoInicioState({
    this.status = CiudadanoInicioStatus.initial,
    this.domicilios = const [],
    this.idDomicilioSeleccionado,
    this.cronogramaStatus = CiudadanoInicioCronogramaStatus.initial,
    this.cronograma,
    this.errorMessage,
    this.statusCode,
    this.cronogramaErrorMessage,
    this.cronogramaStatusCode,
  });

  // *********************************************************
  // INDICADORES
  // *********************************************************

  bool get isLoading => status == CiudadanoInicioStatus.loading;

  bool get isFailure => status == CiudadanoInicioStatus.failure;

  bool get isCronogramaLoading =>
      cronogramaStatus == CiudadanoInicioCronogramaStatus.loading;

  bool get isCronogramaFailure =>
      cronogramaStatus == CiudadanoInicioCronogramaStatus.failure;

  bool get isEmpty =>
      status == CiudadanoInicioStatus.ready && domicilios.isEmpty;

  bool get hasDomicilios => domicilios.isNotEmpty;

  bool get hasProximaRecoleccion => cronograma?.proximaRecoleccion != null;

  GetMisDomiciliosDataModel? get domicilioSeleccionado {
    for (final domicilio in domicilios) {
      if (domicilio.idDomicilio == idDomicilioSeleccionado) {
        return domicilio;
      }
    }

    return null;
  }

  // *********************************************************
  // COPY WITH
  // *********************************************************

  CiudadanoInicioState copyWith({
    CiudadanoInicioStatus? status,
    List<GetMisDomiciliosDataModel>? domicilios,
    int? idDomicilioSeleccionado,
    CiudadanoInicioCronogramaStatus? cronogramaStatus,
    GetDomicilioCronogramaDataModel? cronograma,
    String? errorMessage,
    int? statusCode,
    String? cronogramaErrorMessage,
    int? cronogramaStatusCode,
    bool clearSelection = false,
    bool clearCronograma = false,
    bool clearError = false,
    bool clearCronogramaError = false,
  }) {
    return CiudadanoInicioState(
      status: status ?? this.status,
      domicilios: domicilios ?? this.domicilios,
      idDomicilioSeleccionado: clearSelection
          ? null
          : idDomicilioSeleccionado ?? this.idDomicilioSeleccionado,
      cronogramaStatus: cronogramaStatus ?? this.cronogramaStatus,
      cronograma: clearCronograma ? null : cronograma ?? this.cronograma,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      statusCode: clearError ? null : statusCode ?? this.statusCode,
      cronogramaErrorMessage: clearCronogramaError
          ? null
          : cronogramaErrorMessage ?? this.cronogramaErrorMessage,
      cronogramaStatusCode: clearCronogramaError
          ? null
          : cronogramaStatusCode ?? this.cronogramaStatusCode,
    );
  }
}
