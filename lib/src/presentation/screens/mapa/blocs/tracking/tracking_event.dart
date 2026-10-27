import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class TrackingEvent {
  const TrackingEvent();
}

/// Registrar una ubicación individual.
class TrackingUbicacionRegistrada extends TrackingEvent {
  final RegistrarUbicacionRequest request;

  const TrackingUbicacionRegistrada({required this.request});
}

/// Registrar un lote de ubicaciones.
class TrackingUbicacionesLoteRegistradas extends TrackingEvent {
  final RegistrarUbicacionLoteRequest request;

  const TrackingUbicacionesLoteRegistradas({required this.request});
}
