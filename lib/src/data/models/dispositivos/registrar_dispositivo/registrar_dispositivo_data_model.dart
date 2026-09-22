// *********************************************************
// DATA DEL REGISTRO
// *********************************************************
class RegistrarDispositivoDataModel {
  final DispositivoNotificacionModel dispositivo;
  final bool creado;
  final bool tokenActualizado;

  RegistrarDispositivoDataModel.fromJson(Map<String, dynamic> json)
    : dispositivo = DispositivoNotificacionModel.fromJson(
        Map<String, dynamic>.from(json['dispositivo'] as Map),
      ),
      creado = json['creado'] as bool,
      tokenActualizado = json['token_actualizado'] as bool;
}

// *********************************************************
// DISPOSITIVO
// *********************************************************
class DispositivoNotificacionModel {
  final int idDispositivo;
  final int idUsuario;
  final String identificadorDispositivo;

  final String plataforma;
  final String? nombreDispositivo;
  final String? modeloDispositivo;
  final String? versionSistema;
  final String? versionAplicacion;

  final String permisoNotificaciones;
  final String estadoDispositivo;

  final DateTime? fechaRegistroToken;
  final DateTime? fechaUltimaActividad;
  final DateTime? fechaDesactivacion;
  final String? motivoDesactivacion;

  final DateTime updatedAt;
  final DateTime createdAt;

  final bool tokenRegistrado;

  DispositivoNotificacionModel.fromJson(Map<String, dynamic> json)
    : idDispositivo = (json['id_dispositivo'] as num).toInt(),
      idUsuario = (json['id_usuario'] as num).toInt(),
      identificadorDispositivo = json['identificador_dispositivo'] as String,
      plataforma = json['plataforma'] as String,
      nombreDispositivo = json['nombre_dispositivo'] as String?,
      modeloDispositivo = json['modelo_dispositivo'] as String?,
      versionSistema = json['version_sistema'] as String?,
      versionAplicacion = json['version_aplicacion'] as String?,
      permisoNotificaciones = json['permiso_notificaciones'] as String,
      estadoDispositivo = json['estado_dispositivo'] as String,
      fechaRegistroToken = json['fecha_registro_token'] == null
          ? null
          : DateTime.parse(json['fecha_registro_token'] as String),
      fechaUltimaActividad = json['fecha_ultima_actividad'] == null
          ? null
          : DateTime.parse(json['fecha_ultima_actividad'] as String),
      fechaDesactivacion = json['fecha_desactivacion'] == null
          ? null
          : DateTime.parse(json['fecha_desactivacion'] as String),
      motivoDesactivacion = json['motivo_desactivacion'] as String?,
      updatedAt = DateTime.parse(json['updated_at'] as String),
      createdAt = DateTime.parse(json['created_at'] as String),
      tokenRegistrado = json['token_registrado'] as bool;
}
