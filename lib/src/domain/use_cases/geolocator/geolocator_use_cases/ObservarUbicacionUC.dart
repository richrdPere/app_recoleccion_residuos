import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ObservarUbicacionUC {
  GeolocatorRepository geolocatorRepository;
  ObservarUbicacionUC(this.geolocatorRepository);

  Stream<Resource<UbicacionEntity>> run({
    required ConfiguracionUbicacionEntity configuracion,
  }) => geolocatorRepository.observarUbicacion(configuracion: configuracion);
}
