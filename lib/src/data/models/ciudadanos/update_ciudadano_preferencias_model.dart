import 'get_ciudadano_perfil_model.dart';

// *********************************************************
// REQUEST - ACTUALIZAR PREFERENCIAS DE NOTIFICACIÓN
// *********************************************************

class UpdateCiudadanoPreferenciasRequest {
  final bool notificacionesHabilitadas;
  final bool canalPush;
  final bool canalInterno;

  final bool notificarRecordatorio;
  final bool notificarInicioRuta;
  final bool notificarProximidadVehiculo;
  final bool notificarCambioHorario;
  final bool notificarCambioRuta;
  final bool notificarCancelacion;
  final bool notificarIncidencias;

  final int minutosAnticipacion;
  final String frecuenciaRecordatorio;

  // Formato HH:mm:ss. Ambos null para desactivar el silencio.
  final String? horaSilencioInicio;
  final String? horaSilencioFin;

  const UpdateCiudadanoPreferenciasRequest({
    required this.notificacionesHabilitadas,
    required this.canalPush,
    required this.canalInterno,
    required this.notificarRecordatorio,
    required this.notificarInicioRuta,
    required this.notificarProximidadVehiculo,
    required this.notificarCambioHorario,
    required this.notificarCambioRuta,
    required this.notificarCancelacion,
    required this.notificarIncidencias,
    required this.minutosAnticipacion,
    required this.frecuenciaRecordatorio,
    this.horaSilencioInicio,
    this.horaSilencioFin,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificaciones_habilitadas': notificacionesHabilitadas,
      'canal_push': canalPush,
      'canal_interno': canalInterno,
      'notificar_recordatorio': notificarRecordatorio,
      'notificar_inicio_ruta': notificarInicioRuta,
      'notificar_proximidad_vehiculo': notificarProximidadVehiculo,
      'notificar_cambio_horario': notificarCambioHorario,
      'notificar_cambio_ruta': notificarCambioRuta,
      'notificar_cancelacion': notificarCancelacion,
      'notificar_incidencias': notificarIncidencias,
      'minutos_anticipacion': minutosAnticipacion,
      'frecuencia_recordatorio': frecuenciaRecordatorio.trim().toUpperCase(),
      'hora_silencio_inicio': horaSilencioInicio?.trim(),
      'hora_silencio_fin': horaSilencioFin?.trim(),
    };
  }

  // Permite precargar la edición con las preferencias actuales.
  factory UpdateCiudadanoPreferenciasRequest.fromPreferencias(
    CiudadanoPerfilPreferenciasModel preferencias,
  ) {
    return UpdateCiudadanoPreferenciasRequest(
      notificacionesHabilitadas: preferencias.notificacionesHabilitadas,
      canalPush: preferencias.canalPush,
      canalInterno: preferencias.canalInterno,
      notificarRecordatorio: preferencias.notificarRecordatorio,
      notificarInicioRuta: preferencias.notificarInicioRuta,
      notificarProximidadVehiculo: preferencias.notificarProximidadVehiculo,
      notificarCambioHorario: preferencias.notificarCambioHorario,
      notificarCambioRuta: preferencias.notificarCambioRuta,
      notificarCancelacion: preferencias.notificarCancelacion,
      notificarIncidencias: preferencias.notificarIncidencias,
      minutosAnticipacion: preferencias.minutosAnticipacion,
      frecuenciaRecordatorio: preferencias.frecuenciaRecordatorio,
      horaSilencioInicio: preferencias.horaSilencioInicio,
      horaSilencioFin: preferencias.horaSilencioFin,
    );
  }
}

// *********************************************************
// DATA - PREFERENCIAS ACTUALIZADAS
// *********************************************************

typedef UpdateCiudadanoPreferenciasDataModel = CiudadanoPerfilPreferenciasModel;
