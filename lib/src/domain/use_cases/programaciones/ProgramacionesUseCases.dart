import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class ProgramacionesUseCases {
  GetMisAsignacionesUC getMisAsignaciones;
  GetProgramacionDetalleUC getProgramacionDetalle;
  ResponderAsignacionUC responderAsignacion;

  ProgramacionesUseCases({
    required this.getMisAsignaciones,
    required this.getProgramacionDetalle,
    required this.responderAsignacion,
  });
}
