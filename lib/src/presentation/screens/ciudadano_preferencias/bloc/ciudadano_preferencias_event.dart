import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class CiudadanoPreferenciasEvent {
  const CiudadanoPreferenciasEvent();
}

class CiudadanoPreferenciasRequested extends CiudadanoPreferenciasEvent {
  const CiudadanoPreferenciasRequested();
}

class CiudadanoPreferenciasSubmitted extends CiudadanoPreferenciasEvent {
  final UpdateCiudadanoPreferenciasRequest request;

  const CiudadanoPreferenciasSubmitted({required this.request});
}
