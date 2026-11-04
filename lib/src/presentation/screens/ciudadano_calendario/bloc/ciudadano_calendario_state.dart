import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum CiudadanoCalendarioStatus { initial, loading, ready, failure }

class CiudadanoCalendarioState {
  final DateTime mes;
  final CiudadanoCalendarioStatus status;
  final GetDomicilioCronogramaDataModel? cronograma;
  final String? errorMessage;
  final int? statusCode;

  const CiudadanoCalendarioState({
    required this.mes,
    this.status = CiudadanoCalendarioStatus.initial,
    this.cronograma,
    this.errorMessage,
    this.statusCode,
  });

  bool get isLoading => status == CiudadanoCalendarioStatus.loading;
}
