import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetTotalNoLeidasUC {
  NotificacionesRepository notificacionesRepository;
  GetTotalNoLeidasUC(this.notificacionesRepository);

  Future<Resource<ApiResponse<GetTotalNoLeidasDataModel>>> run() =>
      notificacionesRepository.getTotalNoLeidas();
}
