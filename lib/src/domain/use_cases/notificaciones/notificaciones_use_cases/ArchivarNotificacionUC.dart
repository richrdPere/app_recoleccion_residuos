import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ArchivarNotificacionUC {
  NotificacionesRepository notificacionesRepository;
  ArchivarNotificacionUC(this.notificacionesRepository);

  Future<Resource<ApiResponse<ArchivarNotificacionDataModel>>> run({
    required int id,
  }) => notificacionesRepository.archivarNotificacion(id: id);
}
