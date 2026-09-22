// *********************************************************
// DATA PAGINADA
// *********************************************************
class GetMisNotificacionesDataModel {
  final List<MiNotificacionItemModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  GetMisNotificacionesDataModel.fromJson(Map<String, dynamic> json)
    : items = (json['items'] as List)
          .map(
            (item) => MiNotificacionItemModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      page = (json['page'] as num).toInt(),
      limit = (json['limit'] as num).toInt(),
      total = (json['total'] as num).toInt(),
      totalPages = (json['total_pages'] as num).toInt(),
      hasNextPage = json['has_next_page'] as bool,
      hasPreviousPage = json['has_previous_page'] as bool;
}

// *********************************************************
// REGISTRO DEL DESTINATARIO
// *********************************************************
class MiNotificacionItemModel {
  final int idNotificacionUsuario;
  final int idNotificacion;
  final int idUsuario;

  final bool leida;
  final DateTime? fechaLeida;

  final bool archivada;
  final DateTime? fechaArchivada;

  final String estadoPush;
  final DateTime? fechaUltimoEnvio;
  final int cantidadIntentos;
  final String? ultimoError;

  final DateTime createdAt;
  final DateTime updatedAt;

  final MiNotificacionDetalleModel notificacion;

  MiNotificacionItemModel.fromJson(Map<String, dynamic> json)
    : idNotificacionUsuario = (json['id_notificacion_usuario'] as num).toInt(),
      idNotificacion = (json['id_notificacion'] as num).toInt(),
      idUsuario = (json['id_usuario'] as num).toInt(),
      leida = json['leida'] as bool,
      fechaLeida = json['fecha_leida'] == null
          ? null
          : DateTime.parse(json['fecha_leida'] as String),
      archivada = json['archivada'] as bool,
      fechaArchivada = json['fecha_archivada'] == null
          ? null
          : DateTime.parse(json['fecha_archivada'] as String),
      estadoPush = json['estado_push'] as String,
      fechaUltimoEnvio = json['fecha_ultimo_envio'] == null
          ? null
          : DateTime.parse(json['fecha_ultimo_envio'] as String),
      cantidadIntentos = (json['cantidad_intentos'] as num).toInt(),
      ultimoError = json['ultimo_error'] as String?,
      createdAt = DateTime.parse(json['created_at'] as String),
      updatedAt = DateTime.parse(json['updated_at'] as String),
      notificacion = MiNotificacionDetalleModel.fromJson(
        Map<String, dynamic>.from(json['notificacion'] as Map),
      );
}

// *********************************************************
// NOTIFICACIÓN
// *********************************************************
class MiNotificacionDetalleModel {
  final int idNotificacion;
  final int? idUsuarioCreacion;

  final String tipoNotificacion;
  final String prioridad;
  final String titulo;
  final String mensaje;

  final bool enviarInterna;
  final bool enviarPush;

  final String? tipoEntidad;
  final int? idEntidad;
  final Object? datos;

  final String? claveEvento;
  final DateTime? fechaProgramada;
  final DateTime? fechaExpiracion;

  final String estadoNotificacion;
  final String origen;
  final DateTime? fechaProcesamiento;

  final DateTime createdAt;
  final DateTime updatedAt;

  final MiNotificacionCreadorModel? creador;

  MiNotificacionDetalleModel.fromJson(Map<String, dynamic> json)
    : idNotificacion = (json['id_notificacion'] as num).toInt(),
      idUsuarioCreacion = (json['id_usuario_creacion'] as num?)?.toInt(),
      tipoNotificacion = json['tipo_notificacion'] as String,
      prioridad = json['prioridad'] as String,
      titulo = json['titulo'] as String,
      mensaje = json['mensaje'] as String,
      enviarInterna = json['enviar_interna'] as bool,
      enviarPush = json['enviar_push'] as bool,
      tipoEntidad = json['tipo_entidad'] as String?,
      idEntidad = (json['id_entidad'] as num?)?.toInt(),
      datos = json['datos'],
      claveEvento = json['clave_evento'] as String?,
      fechaProgramada = json['fecha_programada'] == null
          ? null
          : DateTime.parse(json['fecha_programada'] as String),
      fechaExpiracion = json['fecha_expiracion'] == null
          ? null
          : DateTime.parse(json['fecha_expiracion'] as String),
      estadoNotificacion = json['estado_notificacion'] as String,
      origen = json['origen'] as String,
      fechaProcesamiento = json['fecha_procesamiento'] == null
          ? null
          : DateTime.parse(json['fecha_procesamiento'] as String),
      createdAt = DateTime.parse(json['created_at'] as String),
      updatedAt = DateTime.parse(json['updated_at'] as String),
      creador = json['creador'] == null
          ? null
          : MiNotificacionCreadorModel.fromJson(
              Map<String, dynamic>.from(json['creador'] as Map),
            );
}

// *********************************************************
// CREADOR
// *********************************************************
class MiNotificacionCreadorModel {
  final int idUsuario;
  final String username;

  MiNotificacionCreadorModel.fromJson(Map<String, dynamic> json)
    : idUsuario = (json['id_usuario'] as num).toInt(),
      username = json['username'] as String;
}
