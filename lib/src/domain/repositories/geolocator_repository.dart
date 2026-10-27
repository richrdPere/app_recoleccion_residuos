import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class GeolocatorRepository {
  /// 1. Comprueba si el servicio de ubicación está encendido.
  Future<Resource<bool>> estaServicioHabilitado();

  /// 2. Observa si el usuario activa o desactiva el servicio.
  Stream<bool> observarEstadoServicio();

  /// 3. Consulta permisos sin mostrar una solicitud.
  Future<Resource<PermisoUbicacion>> verificarPermiso();

  /// 4. Solicita permiso de ubicación.
 Future<Resource<PermisoUbicacion>> solicitarPermiso();

  /// 5. Obtiene una posición actual.
  Future<Resource<UbicacionEntity>> obtenerUbicacionActual({
    Duration tiempoLimite = const Duration(seconds: 20),
  });

  /// 6. Recupera una posición previamente conocida.
  /// Puede no existir o estar desactualizada.
  Future<Resource<UbicacionEntity?>> obtenerUltimaUbicacion();

  /// 7. Emite posiciones mientras exista una suscripción.
  Stream<Resource<UbicacionEntity>> observarUbicacion({
    required ConfiguracionUbicacionEntity configuracion,
  });

  /// 8. Abre la configuración de permisos de la aplicación.
  Future<Resource<bool>> abrirConfiguracionAplicacion();

  /// 9. Abre la configuración de ubicación del dispositivo.
  Future<Resource<bool>> abrirConfiguracionUbicacion();
}
