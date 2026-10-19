import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class RecorridoEvent {
  const RecorridoEvent();
}

class ObtenerRecorridoActivo extends RecorridoEvent {
  const ObtenerRecorridoActivo();
}

class ObtenerMisRecorridos extends RecorridoEvent {
  final int page;
  final int limit;

  const ObtenerMisRecorridos({this.page = 1, this.limit = 10});
}

class ObtenerRecorridoDetalle extends RecorridoEvent {
  final int idRecorrido;

  const ObtenerRecorridoDetalle({required this.idRecorrido});
}

class IniciarRecorrido extends RecorridoEvent {
  final int idProgramacion;
  final IniciarRecorridoRequest request;

  const IniciarRecorrido({required this.idProgramacion, required this.request});
}

class PausarRecorrido extends RecorridoEvent {
  final int idRecorrido;
  final PausarRecorridoRequest request;

  const PausarRecorrido({required this.idRecorrido, required this.request});
}

class ReanudarRecorrido extends RecorridoEvent {
  final int idRecorrido;
  final ReanudarRecorridoRequest request;

  const ReanudarRecorrido({required this.idRecorrido, required this.request});
}

class FinalizarRecorrido extends RecorridoEvent {
  final int idRecorrido;
  final FinalizarRecorridoRequest request;

  const FinalizarRecorrido({required this.idRecorrido, required this.request});
}

/// Limpia el resultado de una acción después de mostrar su mensaje.
class LimpiarResultadoAccion extends RecorridoEvent {
  const LimpiarResultadoAccion();
}
