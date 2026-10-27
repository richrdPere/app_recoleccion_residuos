
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';


class GeolocatorUseCases {
  AbrirConfiguracionAplicacionUC abrirConfiguracionAplicacion;
  AbrirConfiguracionUbicacionUC abrirConfiguracionUbicacion;
  EstaServicioHabilitadoUC estaServicioHabilitado;
  ObservarEstadoServicioUC observarEstadoServicio;
  ObservarUbicacionUC observarUbicacion;
  ObtenerUbicacionActualUC obtenerUbicacionActual;
  ObtenerUltimaUbicacionUC obtenerUltimaUbicacion;
  SolicitarPermisoUC solicitarPermiso;
  VerificarPermisoUC verificarPermiso;

  GeolocatorUseCases({
    required this.abrirConfiguracionAplicacion,
    required this.abrirConfiguracionUbicacion,
    required this.estaServicioHabilitado,
    required this.observarEstadoServicio,
    required this.observarUbicacion,
    required this.obtenerUbicacionActual,
    required this.obtenerUltimaUbicacion,
    required this.solicitarPermiso,
    required this.verificarPermiso,
  });
}
