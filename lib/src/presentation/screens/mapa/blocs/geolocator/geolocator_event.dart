import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

abstract class GeolocatorEvent {
  const GeolocatorEvent();
}

// *********************************************************
// SERVICIO DE UBICACIÓN
// *********************************************************

abstract class ServicioGeolocatorEvent extends GeolocatorEvent {
  const ServicioGeolocatorEvent();
}

class VerificarServicioGeolocator extends ServicioGeolocatorEvent {
  const VerificarServicioGeolocator();
}

class ObservarServicioGeolocator extends ServicioGeolocatorEvent {
  const ObservarServicioGeolocator();
}

class DetenerObservacionServicioGeolocator extends ServicioGeolocatorEvent {
  const DetenerObservacionServicioGeolocator();
}

// *********************************************************
// PERMISOS
// *********************************************************

abstract class PermisoGeolocatorEvent extends GeolocatorEvent {
  const PermisoGeolocatorEvent();
}

class VerificarPermisoGeolocator extends PermisoGeolocatorEvent {
  const VerificarPermisoGeolocator();
}

class SolicitarPermisoGeolocator extends PermisoGeolocatorEvent {
  const SolicitarPermisoGeolocator();
}

// *********************************************************
// UBICACIÓN ACTUAL
// *********************************************************

class ObtenerUbicacionActualGeolocator extends GeolocatorEvent {
  final Duration tiempoLimite;

  const ObtenerUbicacionActualGeolocator({
    this.tiempoLimite = const Duration(seconds: 20),
  });
}

// *********************************************************
// ÚLTIMA UBICACIÓN
// *********************************************************

class ObtenerUltimaUbicacionGeolocator extends GeolocatorEvent {
  const ObtenerUltimaUbicacionGeolocator();
}

// *********************************************************
// SEGUIMIENTO DE UBICACIÓN
// *********************************************************

abstract class SeguimientoGeolocatorEvent extends GeolocatorEvent {
  const SeguimientoGeolocatorEvent();
}

class IniciarSeguimientoGeolocator extends SeguimientoGeolocatorEvent {
  final ConfiguracionUbicacionEntity configuracion;

  const IniciarSeguimientoGeolocator({required this.configuracion});
}

class DetenerSeguimientoGeolocator extends SeguimientoGeolocatorEvent {
  const DetenerSeguimientoGeolocator();
}

// *********************************************************
// CONFIGURACIÓN DEL DISPOSITIVO
// *********************************************************

abstract class ConfiguracionGeolocatorEvent extends GeolocatorEvent {
  const ConfiguracionGeolocatorEvent();
}

class AbrirConfiguracionAplicacionGeolocator
    extends ConfiguracionGeolocatorEvent {
  const AbrirConfiguracionAplicacionGeolocator();
}

class AbrirConfiguracionUbicacionGeolocator
    extends ConfiguracionGeolocatorEvent {
  const AbrirConfiguracionUbicacionGeolocator();
}
