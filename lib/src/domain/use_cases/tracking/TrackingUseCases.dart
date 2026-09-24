import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class TrackingUseCases {
  RegistrarUbicacionLoteUC registrarUbicacionLote;
  RegistrarUbicacionUC registrarUbicacion;

  TrackingUseCases({
    required this.registrarUbicacionLote,
    required this.registrarUbicacion,
  });
}
