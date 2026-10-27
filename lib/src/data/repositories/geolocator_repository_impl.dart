// Services
import 'package:app_recoleccion_residuos/src/data/datasources/local/local.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class GeolocatorRepositoryImpl implements GeolocatorRepository {
  final GeolocatorService geolocatorService;

  GeolocatorRepositoryImpl(this.geolocatorService);

  // *********************************************************
  // 1. VERIFICAR SERVICIO DE UBICACIÓN
  // *********************************************************
  @override
  Future<Resource<bool>> estaServicioHabilitado() async {
    return await geolocatorService.estaServicioHabilitado();
  }

  // *********************************************************
  // 2. OBSERVAR ESTADO DEL SERVICIO DE UBICACIÓN
  // *********************************************************
  @override
  Stream<bool> observarEstadoServicio() {
    return geolocatorService.observarEstadoServicio();
  }

  // *********************************************************
  // 3. VERIFICAR PERMISO
  // *********************************************************
  @override
  Future<Resource<PermisoUbicacion>> verificarPermiso() async {
    return await geolocatorService.verificarPermiso();
  }

  // *********************************************************
  // 4. SOLICITAR PERMISO
  // *********************************************************
  @override
  Future<Resource<PermisoUbicacion>> solicitarPermiso() async {
    return await geolocatorService.solicitarPermiso();
  }

  // *********************************************************
  // 5. OBTENER UBICACIÓN ACTUAL
  // *********************************************************
  @override
  Future<Resource<UbicacionEntity>> obtenerUbicacionActual({
    Duration tiempoLimite = const Duration(seconds: 20),
  }) async {
    if (tiempoLimite <= Duration.zero) {
      return ErrorData(message: 'El tiempo límite debe ser mayor que cero.');
    }

    return await geolocatorService.obtenerUbicacionActual(
      tiempoLimite: tiempoLimite,
    );
  }

  // *********************************************************
  // 6. OBTENER ÚLTIMA UBICACIÓN CONOCIDA
  // *********************************************************
  @override
  Future<Resource<UbicacionEntity?>> obtenerUltimaUbicacion() async {
    return await geolocatorService.obtenerUltimaUbicacion();
  }

  // *********************************************************
  // 7. OBSERVAR UBICACIÓN
  // *********************************************************
  @override
  Stream<Resource<UbicacionEntity>> observarUbicacion({
    required ConfiguracionUbicacionEntity configuracion,
  }) {
    return geolocatorService.observarUbicacion(configuracion: configuracion);
  }

  // *********************************************************
  // 8. ABRIR CONFIGURACIÓN DE LA APLICACIÓN
  // *********************************************************
  @override
  Future<Resource<bool>> abrirConfiguracionAplicacion() async {
    return await geolocatorService.abrirConfiguracionAplicacion();
  }

  // *********************************************************
  // 9. ABRIR CONFIGURACIÓN DE UBICACIÓN
  // *********************************************************
  @override
  Future<Resource<bool>> abrirConfiguracionUbicacion() async {
    return await geolocatorService.abrirConfiguracionUbicacion();
  }
}
