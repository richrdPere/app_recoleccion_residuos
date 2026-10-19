import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetCiudadanoPreferenciasUC {
  PrefNotificationRepository prefNotificationRepository;
  GetCiudadanoPreferenciasUC(this.prefNotificationRepository);

  Future<Resource<ApiResponse<GetCiudadanoPreferenciasDataModel>>> run() =>
      prefNotificationRepository.getCiudadanoPreferencias();
}
