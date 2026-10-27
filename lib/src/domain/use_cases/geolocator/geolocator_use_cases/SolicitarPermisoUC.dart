import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class SolicitarPermisoUC {
  GeolocatorRepository geolocatorRepository;
  SolicitarPermisoUC(this.geolocatorRepository);

  Future<Resource<PermisoUbicacion>> run() =>
      geolocatorRepository.solicitarPermiso();
}
