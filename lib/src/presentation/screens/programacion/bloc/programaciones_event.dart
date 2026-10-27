import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class ProgramacionesEvent {
  const ProgramacionesEvent();
}

// *********************************************************
// 1. OBTENER MIS ASIGNACIONES
// *********************************************************

class ObtenerMisAsignaciones extends ProgramacionesEvent {
  final MisAsignacionesFilters filters;

  const ObtenerMisAsignaciones({required this.filters});
}

// *********************************************************
// 2. OBTENER DETALLE DE PROGRAMACIÓN
// *********************************************************

class ObtenerProgramacionDetalle extends ProgramacionesEvent {
  final int idProgramacion;

  const ObtenerProgramacionDetalle({required this.idProgramacion});
}

// *********************************************************
// 3. RESPONDER ASIGNACIÓN
// *********************************************************

class ResponderAsignacion extends ProgramacionesEvent {
  final int idProgramacionPersonal;
  final ResponderAsignacionRequest request;

  const ResponderAsignacion({
    required this.idProgramacionPersonal,
    required this.request,
  });
}
