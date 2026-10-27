import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ObtenerUbicacionActualUC {
  GeolocatorRepository geolocatorRepository;
  ObtenerUbicacionActualUC(this.geolocatorRepository);

  Future<Resource<UbicacionEntity>> run({
    Duration tiempoLimite = const Duration(seconds: 20),
  }) => geolocatorRepository.obtenerUbicacionActual(tiempoLimite: tiempoLimite);
}
