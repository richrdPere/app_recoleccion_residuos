import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetNotificacionByIdUC {
  NotificacionesRepository notificacionesRepository;
  GetNotificacionByIdUC(this.notificacionesRepository);

  Future<Resource<ApiResponse<GetNotificacionByIdDataModel>>> run({
    required int id,
  }) => notificacionesRepository.getNotificacionById(id: id);
}
