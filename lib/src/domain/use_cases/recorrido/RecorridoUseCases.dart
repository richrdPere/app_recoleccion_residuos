import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class RecorridoUsecases {
  FinalizarRecorridoUC finalizarRecorrido;
  GetMisRecorridosUC getMisRecorridos;
  GetRecorridoActivoUC getRecorridoActivo;
  GetRecorridoByIdUC getRecorridoById;
  IniciarRecorridoUC iniciarRecorrido;
  PausarRecorridoUC pausarRecorrido;
  ReanudarRecorridoUC reanudarRecorrido;

  RecorridoUsecases({
    required this.finalizarRecorrido,
    required this.getMisRecorridos,
    required this.getRecorridoActivo,
    required this.getRecorridoById,
    required this.iniciarRecorrido,
    required this.pausarRecorrido,
    required this.reanudarRecorrido,
  });
}
