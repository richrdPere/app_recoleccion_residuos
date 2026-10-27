import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class AbrirConfiguracionUbicacionUC {
  GeolocatorRepository geolocatorRepository;
  AbrirConfiguracionUbicacionUC(this.geolocatorRepository);

  Future<Resource<bool>> run() =>
      geolocatorRepository.abrirConfiguracionUbicacion();
}
