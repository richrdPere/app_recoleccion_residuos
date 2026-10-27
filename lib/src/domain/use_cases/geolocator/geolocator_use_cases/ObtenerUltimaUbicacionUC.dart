import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ObtenerUltimaUbicacionUC {
  GeolocatorRepository geolocatorRepository;
  ObtenerUltimaUbicacionUC(this.geolocatorRepository);

  Future<Resource<UbicacionEntity?>> run() =>
      geolocatorRepository.obtenerUltimaUbicacion();
}
