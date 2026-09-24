import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RegistrarUbicacionLoteUC {
  TrackingRepository trackingRepository;
  RegistrarUbicacionLoteUC(this.trackingRepository);

  Future<Resource<ApiResponse<RegistrarUbicacionLoteDataModel>>> run({
    required RegistrarUbicacionLoteRequest request,
  }) => trackingRepository.registrarUbicacionLote(request: request);
}
