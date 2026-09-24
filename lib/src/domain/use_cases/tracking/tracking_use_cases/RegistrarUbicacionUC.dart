import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RegistrarUbicacionUC {
  TrackingRepository trackingRepository;
  RegistrarUbicacionUC(this.trackingRepository);

  Future<Resource<ApiResponse<RegistrarUbicacionDataModel>>> run({
    required RegistrarUbicacionRequest request,
  }) => trackingRepository.registrarUbicacion(request: request);
}
