import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum CiudadanoMapaStatus {
  initial,
  cargandoDomicilios,
  cargandoServicio,
  listo,
  error,
}

class CiudadanoMapaState {
  final CiudadanoMapaStatus status;

  final List<GetMisDomiciliosDataModel> domicilios;
  final int? idDomicilioSeleccionado;

  final GetDomicilioServicioActivoDataModel? datos;

  final String? errorMessage;

  /// Permite decidir si reintentar domicilios o solo el servicio.
  final bool errorEnDomicilios;

  const CiudadanoMapaState({
    this.status = CiudadanoMapaStatus.initial,
    this.domicilios = const [],
    this.idDomicilioSeleccionado,
    this.datos,
    this.errorMessage,
    this.errorEnDomicilios = false,
  });

  bool get isBusy =>
      status == CiudadanoMapaStatus.cargandoDomicilios ||
      status == CiudadanoMapaStatus.cargandoServicio;

  bool get isInitial => status == CiudadanoMapaStatus.initial;
}
