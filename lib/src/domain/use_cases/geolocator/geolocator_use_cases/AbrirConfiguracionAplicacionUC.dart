import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class AbrirConfiguracionAplicacionUC {
  GeolocatorRepository geolocatorRepository;
  AbrirConfiguracionAplicacionUC(this.geolocatorRepository);

  Future<Resource<bool>> run() =>
      geolocatorRepository.abrirConfiguracionAplicacion();
}
