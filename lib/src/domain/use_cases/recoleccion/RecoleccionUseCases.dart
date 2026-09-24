import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class RecoleccionUseCases {
  GetPuntosRecorridoUC getPuntosRecorrido;
  GetRecoleccionByIdUC getRecoleccionById;
  GetRecorridoProgresoUC getRecorridoProgreso;
  RegistrarEvidenciaUC registrarEvidencia;
  RegistrarRecoleccionLoteUC registrarRecoleccionLote;
  RegistrarRecoleccionUC registrarRecoleccion;

  RecoleccionUseCases({
    required this.getPuntosRecorrido,
    required this.getRecoleccionById,
    required this.getRecorridoProgreso,
    required this.registrarEvidencia,
    required this.registrarRecoleccionLote,
    required this.registrarRecoleccion,
  });
}
