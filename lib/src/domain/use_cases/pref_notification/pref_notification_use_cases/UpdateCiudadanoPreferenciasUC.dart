import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class UpdateCiudadanoPreferenciasUC {
  PrefNotificationRepository prefNotificationRepository;
  UpdateCiudadanoPreferenciasUC(this.prefNotificationRepository);

  Future<Resource<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>> run({
    required UpdateCiudadanoPreferenciasRequest request,
  }) =>
      prefNotificationRepository.updateCiudadanoPreferencias(request: request);
}
