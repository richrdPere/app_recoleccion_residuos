import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

class ObservarEstadoServicioUC {
  GeolocatorRepository geolocatorRepository;
  ObservarEstadoServicioUC(this.geolocatorRepository);

  Stream<bool> run() => geolocatorRepository.observarEstadoServicio();
}
