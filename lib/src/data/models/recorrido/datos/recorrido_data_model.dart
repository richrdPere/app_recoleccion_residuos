// ======================================================
// CONVERSIÓN DE NÚMEROS
// Soporta números JSON y decimales enviados como String.
// ======================================================

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();

  return double.parse(value.toString());
}

// ======================================================
// RECORRIDO
// ======================================================

class RecorridoDataModel {
  final int idRecorrido;
  final int idProgramacion;
  final int idUsuarioInicio;
  final int? idUsuarioFinalizacion;

  final String estadoRecorrido;
  final String fechaHoraInicio;
  final String? fechaHoraFinalizacion;

  final double? latitudInicio;
  final double? longitudInicio;
  final double? precisionInicio;

  final double? latitudFinalizacion;
  final double? longitudFinalizacion;
  final double? precisionFinalizacion;

  final double? kilometrajeInicio;
  final double? kilometrajeFinal;
  final double? distanciaRecorridaMetros;
  final int? duracionSegundos;

  final String? observacionInicio;
  final String? observacionFinalizacion;
  final String? motivoCancelacion;

  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  final RecorridoProgramacionModel programacion;
  final RecorridoUsuarioModel usuarioInicio;
  final RecorridoUsuarioModel? usuarioFinalizacion;
  final List<RecorridoEventoModel> eventos;

  RecorridoDataModel.fromJson(Map<String, dynamic> json)
    : idRecorrido = (json['id_recorrido'] as num).toInt(),
      idProgramacion = (json['id_programacion'] as num).toInt(),
      idUsuarioInicio = (json['id_usuario_inicio'] as num).toInt(),
      idUsuarioFinalizacion = (json['id_usuario_finalizacion'] as num?)
          ?.toInt(),
      estadoRecorrido = json['estado_recorrido'] as String,
      fechaHoraInicio = json['fecha_hora_inicio'] as String,
      fechaHoraFinalizacion = json['fecha_hora_finalizacion'] as String?,
      latitudInicio = _parseDouble(json['latitud_inicio']),
      longitudInicio = _parseDouble(json['longitud_inicio']),
      precisionInicio = _parseDouble(json['precision_inicio']),
      latitudFinalizacion = _parseDouble(json['latitud_finalizacion']),
      longitudFinalizacion = _parseDouble(json['longitud_finalizacion']),
      precisionFinalizacion = _parseDouble(json['precision_finalizacion']),
      kilometrajeInicio = _parseDouble(json['kilometraje_inicio']),
      kilometrajeFinal = _parseDouble(json['kilometraje_final']),
      distanciaRecorridaMetros = _parseDouble(
        json['distancia_recorrida_metros'],
      ),
      duracionSegundos = (json['duracion_segundos'] as num?)?.toInt(),
      observacionInicio = json['observacion_inicio'] as String?,
      observacionFinalizacion = json['observacion_finalizacion'] as String?,
      motivoCancelacion = json['motivo_cancelacion'] as String?,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?,
      programacion = RecorridoProgramacionModel.fromJson(
        Map<String, dynamic>.from(json['programacion'] as Map),
      ),
      usuarioInicio = RecorridoUsuarioModel.fromJson(
        Map<String, dynamic>.from(json['usuario_inicio'] as Map),
      ),
      usuarioFinalizacion = json['usuario_finalizacion'] == null
          ? null
          : RecorridoUsuarioModel.fromJson(
              Map<String, dynamic>.from(json['usuario_finalizacion'] as Map),
            ),
      eventos = (json['eventos'] as List)
          .map(
            (item) => RecorridoEventoModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
}

// ======================================================
// PROGRAMACIÓN ASOCIADA
// ======================================================

class RecorridoProgramacionModel {
  final int idProgramacion;
  final int idRuta;
  final int idRutaVersion;
  final int idVehiculo;
  final int idUsuarioCreacion;

  final String fechaProgramada;
  final String horaInicioProgramada;
  final String horaFinProgramada;
  final String turno;
  final String estadoProgramacion;

  final String? observacion;
  final String? motivoCancelacion;
  final String? fechaCancelacion;

  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  RecorridoProgramacionModel.fromJson(Map<String, dynamic> json)
    : idProgramacion = (json['id_programacion'] as num).toInt(),
      idRuta = (json['id_ruta'] as num).toInt(),
      idRutaVersion = (json['id_ruta_version'] as num).toInt(),
      idVehiculo = (json['id_vehiculo'] as num).toInt(),
      idUsuarioCreacion = (json['id_usuario_creacion'] as num).toInt(),
      fechaProgramada = json['fecha_programada'] as String,
      horaInicioProgramada = json['hora_inicio_programada'] as String,
      horaFinProgramada = json['hora_fin_programada'] as String,
      turno = json['turno'] as String,
      estadoProgramacion = json['estado_programacion'] as String,
      observacion = json['observacion'] as String?,
      motivoCancelacion = json['motivo_cancelacion'] as String?,
      fechaCancelacion = json['fecha_cancelacion'] as String?,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?;
}

// ======================================================
// USUARIO
// email_acceso no aparece en el usuario del evento.
// ======================================================

class RecorridoUsuarioModel {
  final int idUsuario;
  final String username;
  final String? emailAcceso;

  RecorridoUsuarioModel.fromJson(Map<String, dynamic> json)
    : idUsuario = (json['id_usuario'] as num).toInt(),
      username = json['username'] as String,
      emailAcceso = json['email_acceso'] as String?;
}

// ======================================================
// EVENTO
// ======================================================

class RecorridoEventoModel {
  final int idRecorridoEvento;
  final int idRecorrido;
  final int idUsuario;

  final String tipoEvento;
  final String fechaEvento;
  final String fechaRecepcion;

  final double? latitud;
  final double? longitud;
  final double? precisionGps;

  final String? observacion;
  final String? claveIdempotencia;

  // La respuesta solo muestra null; se conserva como JSON
  // hasta conocer la estructura de este campo.
  final Object? datos;

  final String origen;
  final String? ip;
  final String? userAgent;
  final String createdAt;

  final RecorridoUsuarioModel usuario;

  RecorridoEventoModel.fromJson(Map<String, dynamic> json)
    : idRecorridoEvento = (json['id_recorrido_evento'] as num).toInt(),
      idRecorrido = (json['id_recorrido'] as num).toInt(),
      idUsuario = (json['id_usuario'] as num).toInt(),
      tipoEvento = json['tipo_evento'] as String,
      fechaEvento = json['fecha_evento'] as String,
      fechaRecepcion = json['fecha_recepcion'] as String,
      latitud = _parseDouble(json['latitud']),
      longitud = _parseDouble(json['longitud']),
      precisionGps = _parseDouble(json['precision_gps']),
      observacion = json['observacion'] as String?,
      claveIdempotencia = json['clave_idempotencia'] as String?,
      datos = json['datos'],
      origen = json['origen'] as String,
      ip = json['ip'] as String?,
      userAgent = json['user_agent'] as String?,
      createdAt = json['created_at'] as String,
      usuario = RecorridoUsuarioModel.fromJson(
        Map<String, dynamic>.from(json['usuario'] as Map),
      );
}
