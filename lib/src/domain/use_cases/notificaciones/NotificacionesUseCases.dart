import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class NotificacionesUseCases {
  ArchivarNotificacionUC archivarNotificacion;
  GetMisNotificacionesUC getMisNotificaciones;
  GetNotificacionByIdUC getNotificacionById;
  GetTotalNoLeidasUC getTotalNoLeidas;
  MarcarNotificacionLeidaUC marcarNotificacionLeida;
  MarcarTodasNotificacionesLeidasUC marcarTodasNotificacionesLeidas;

  NotificacionesUseCases({
    required this.archivarNotificacion,
    required this.getMisNotificaciones,
    required this.getNotificacionById,
    required this.getTotalNoLeidas,
    required this.marcarNotificacionLeida,
    required this.marcarTodasNotificacionesLeidas,
  });
}
