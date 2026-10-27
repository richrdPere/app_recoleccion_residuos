import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class EstaServicioHabilitadoUC {
  GeolocatorRepository geolocatorRepository;
  EstaServicioHabilitadoUC(this.geolocatorRepository);

  Future<Resource<bool>> run() => geolocatorRepository.estaServicioHabilitado();
}
