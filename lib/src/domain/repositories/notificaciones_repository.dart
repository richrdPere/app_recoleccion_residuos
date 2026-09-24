import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class NotificacionesRepository {
  /// 1. OBTENER MIS NOTIFICACIONES
  Future<Resource<ApiResponse<GetMisNotificacionesDataModel>>>
  getMisNotificaciones({required GetMisNotificacionesRequest query});

  /// 2. OBTENER TOTAL DE NOTIFICACIONES NO LEÍDAS
  Future<Resource<ApiResponse<GetTotalNoLeidasDataModel>>> getTotalNoLeidas();

  /// 3. OBTENER NOTIFICACIÓN POR ID
  Future<Resource<ApiResponse<GetNotificacionByIdDataModel>>>
  getNotificacionById({required int id});

  /// 4. MARCAR NOTIFICACIÓN COMO LEÍDA
  Future<Resource<ApiResponse<MarcarNotificacionLeidaDataModel>>>
  marcarNotificacionLeida({required int id});

  // 5. MARCAR TODAS LAS NOTIFICACIONES COMO LEÍDAS
  Future<Resource<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>>
  marcarTodasNotificacionesLeidas();

  // 6. ARCHIVAR NOTIFICACIÓN
  Future<Resource<ApiResponse<ArchivarNotificacionDataModel>>>
  archivarNotificacion({required int id});
}
