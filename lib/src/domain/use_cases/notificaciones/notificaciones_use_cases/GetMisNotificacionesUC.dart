import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetMisNotificacionesUC {
  NotificacionesRepository notificacionesRepository;
  GetMisNotificacionesUC(this.notificacionesRepository);

  Future<Resource<ApiResponse<GetMisNotificacionesDataModel>>> run({
    required GetMisNotificacionesRequest query,
  }) => notificacionesRepository.getMisNotificaciones(query: query);
}
