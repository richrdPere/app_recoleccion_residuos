import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class MarcarNotificacionLeidaUC {
  NotificacionesRepository notificacionesRepository;
  MarcarNotificacionLeidaUC(this.notificacionesRepository);

  Future<Resource<ApiResponse<MarcarNotificacionLeidaDataModel>>> run({
    required int id,
  }) => notificacionesRepository.marcarNotificacionLeida(id: id);
}
