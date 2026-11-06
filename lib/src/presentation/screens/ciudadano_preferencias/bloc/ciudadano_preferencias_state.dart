import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum CiudadanoPreferenciasStatus {
  initial,
  loading,
  ready,
  saving,
  failure,
  saved,
}

class CiudadanoPreferenciasState {
  final CiudadanoPreferenciasStatus status;
  final CiudadanoPerfilPreferenciasModel? preferencias;

  final String? errorMessage;
  final int? statusCode;

  // Cambia al recibir datos nuevos del servidor.
  final int revision;

  const CiudadanoPreferenciasState({
    this.status = CiudadanoPreferenciasStatus.initial,
    this.preferencias,
    this.errorMessage,
    this.statusCode,
    this.revision = 0,
  });

  bool get isBusy =>
      status == CiudadanoPreferenciasStatus.loading ||
      status == CiudadanoPreferenciasStatus.saving;
}
