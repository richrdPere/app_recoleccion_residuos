import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class MarcarTodasNotificacionesLeidasUC {
  NotificacionesRepository notificacionesRepository;
  MarcarTodasNotificacionesLeidasUC(this.notificacionesRepository);

  Future<Resource<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>>
  run() => notificacionesRepository.marcarTodasNotificacionesLeidas();
}
