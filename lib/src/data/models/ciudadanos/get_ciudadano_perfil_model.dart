// *********************************************************
// DATA - MI PERFIL CIUDADANO
// *********************************************************

class GetCiudadanoPerfilDataModel {
  final int idCiudadano;
  final int idUsuario;

  final bool aceptaTratamientoDatos;
  final DateTime? fechaConsentimiento;
  final String? versionConsentimiento;
  final String origenRegistro;

  final bool celularVerificado;
  final DateTime? fechaVerificacionCelular;

  final String estadoCiudadano;
  final DateTime? fechaActivacion;
  final DateTime? fechaDesactivacion;
  final String? motivoDesactivacion;
  final String? observacion;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  final CiudadanoPerfilUsuarioModel usuario;

  // Pendiente tipar al conocer el JSON de un domicilio.
  final List<Map<String, dynamic>> domicilios;

  final CiudadanoPerfilPreferenciasModel? preferenciasNotificacion;

  const GetCiudadanoPerfilDataModel({
    required this.idCiudadano,
    required this.idUsuario,
    required this.aceptaTratamientoDatos,
    this.fechaConsentimiento,
    this.versionConsentimiento,
    required this.origenRegistro,
    required this.celularVerificado,
    this.fechaVerificacionCelular,
    required this.estadoCiudadano,
    this.fechaActivacion,
    this.fechaDesactivacion,
    this.motivoDesactivacion,
    this.observacion,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.usuario,
    required this.domicilios,
    this.preferenciasNotificacion,
  });

  factory GetCiudadanoPerfilDataModel.fromJson(Map<String, dynamic> json) {
    return GetCiudadanoPerfilDataModel(
      idCiudadano: _perfilId(json['id_ciudadano']),
      idUsuario: _perfilId(json['id_usuario']),
      aceptaTratamientoDatos: json['acepta_tratamiento_datos'] as bool,
      fechaConsentimiento: _perfilDate(json['fecha_consentimiento']),
      versionConsentimiento: json['version_consentimiento'] as String?,
      origenRegistro: json['origen_registro'] as String,
      celularVerificado: json['celular_verificado'] as bool,
      fechaVerificacionCelular: _perfilDate(json['fecha_verificacion_celular']),
      estadoCiudadano: json['estado_ciudadano'] as String,
      fechaActivacion: _perfilDate(json['fecha_activacion']),
      fechaDesactivacion: _perfilDate(json['fecha_desactivacion']),
      motivoDesactivacion: json['motivo_desactivacion'] as String?,
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _perfilDate(json['deleted_at']),
      usuario: CiudadanoPerfilUsuarioModel.fromJson(
        Map<String, dynamic>.from(json['usuario'] as Map),
      ),
      domicilios: (json['domicilios'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false),
      preferenciasNotificacion: json['preferencias_notificacion'] == null
          ? null
          : CiudadanoPerfilPreferenciasModel.fromJson(
              Map<String, dynamic>.from(
                json['preferencias_notificacion'] as Map,
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ciudadano': idCiudadano,
      'id_usuario': idUsuario,
      'acepta_tratamiento_datos': aceptaTratamientoDatos,
      'fecha_consentimiento': _perfilDateJson(fechaConsentimiento),
      'version_consentimiento': versionConsentimiento,
      'origen_registro': origenRegistro,
      'celular_verificado': celularVerificado,
      'fecha_verificacion_celular': _perfilDateJson(fechaVerificacionCelular),
      'estado_ciudadano': estadoCiudadano,
      'fecha_activacion': _perfilDateJson(fechaActivacion),
      'fecha_desactivacion': _perfilDateJson(fechaDesactivacion),
      'motivo_desactivacion': motivoDesactivacion,
      'observacion': observacion,
      'created_at': _perfilDateJson(createdAt),
      'updated_at': _perfilDateJson(updatedAt),
      'deleted_at': _perfilDateJson(deletedAt),
      'usuario': usuario.toJson(),
      'domicilios': domicilios,
      'preferencias_notificacion': preferenciasNotificacion?.toJson(),
    };
  }
}

// *********************************************************
// USUARIO
// *********************************************************

class CiudadanoPerfilUsuarioModel {
  final int idUsuario;
  final String username;
  final String emailAcceso;
  final CiudadanoPerfilPersonaModel persona;

  const CiudadanoPerfilUsuarioModel({
    required this.idUsuario,
    required this.username,
    required this.emailAcceso,
    required this.persona,
  });

  factory CiudadanoPerfilUsuarioModel.fromJson(Map<String, dynamic> json) {
    return CiudadanoPerfilUsuarioModel(
      idUsuario: _perfilId(json['id_usuario']),
      username: json['username'] as String,
      emailAcceso: json['email_acceso'] as String,
      persona: CiudadanoPerfilPersonaModel.fromJson(
        Map<String, dynamic>.from(json['persona'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'username': username,
      'email_acceso': emailAcceso,
      'persona': persona.toJson(),
    };
  }
}

// *********************************************************
// PERSONA
// *********************************************************

class CiudadanoPerfilPersonaModel {
  final int idPersona;
  final String nombres;
  final String apellidos;
  final String? emailContacto;
  final String tipoDocumento;
  final String numeroDocumento;

  // DATEONLY: conservar como YYYY-MM-DD.
  final String? fechaNacimiento;

  final String? celular;
  final String? direccion;
  final String? fotoUrl;
  final String? genero;
  final bool estado;

  final DateTime createdAt;
  final DateTime updatedAt;

  const CiudadanoPerfilPersonaModel({
    required this.idPersona,
    required this.nombres,
    required this.apellidos,
    this.emailContacto,
    required this.tipoDocumento,
    required this.numeroDocumento,
    this.fechaNacimiento,
    this.celular,
    this.direccion,
    this.fotoUrl,
    this.genero,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();

  factory CiudadanoPerfilPersonaModel.fromJson(Map<String, dynamic> json) {
    return CiudadanoPerfilPersonaModel(
      idPersona: _perfilId(json['id_persona']),
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      emailContacto: json['email_contacto'] as String?,
      tipoDocumento: json['tipo_documento'] as String,
      numeroDocumento: json['numero_documento'] as String,
      fechaNacimiento: json['fecha_nacimiento'] as String?,
      celular: json['celular'] as String?,
      direccion: json['direccion'] as String?,
      fotoUrl: json['foto_url'] as String?,
      genero: json['genero'] as String?,
      estado: json['estado'] as bool,

      // Persona usa nombres de timestamps diferentes.
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_persona': idPersona,
      'nombres': nombres,
      'apellidos': apellidos,
      'email_contacto': emailContacto,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      'fecha_nacimiento': fechaNacimiento,
      'celular': celular,
      'direccion': direccion,
      'foto_url': fotoUrl,
      'genero': genero,
      'estado': estado,
      'createdAt': _perfilDateJson(createdAt),
      'updatedAt': _perfilDateJson(updatedAt),
    };
  }
}

// *********************************************************
// PREFERENCIAS DE NOTIFICACIÓN
// *********************************************************

class CiudadanoPerfilPreferenciasModel {
  final int idPreferencia;
  final int idCiudadano;

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

  // Horarios, no fechas completas.
  final String? horaSilencioInicio;
  final String? horaSilencioFin;

  final String estadoPreferencia;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CiudadanoPerfilPreferenciasModel({
    required this.idPreferencia,
    required this.idCiudadano,
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
    required this.estadoPreferencia,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CiudadanoPerfilPreferenciasModel.fromJson(Map<String, dynamic> json) {
    return CiudadanoPerfilPreferenciasModel(
      idPreferencia: _perfilId(json['id_preferencia']),
      idCiudadano: _perfilId(json['id_ciudadano']),
      notificacionesHabilitadas: json['notificaciones_habilitadas'] as bool,
      canalPush: json['canal_push'] as bool,
      canalInterno: json['canal_interno'] as bool,
      notificarRecordatorio: json['notificar_recordatorio'] as bool,
      notificarInicioRuta: json['notificar_inicio_ruta'] as bool,
      notificarProximidadVehiculo:
          json['notificar_proximidad_vehiculo'] as bool,
      notificarCambioHorario: json['notificar_cambio_horario'] as bool,
      notificarCambioRuta: json['notificar_cambio_ruta'] as bool,
      notificarCancelacion: json['notificar_cancelacion'] as bool,
      notificarIncidencias: json['notificar_incidencias'] as bool,
      minutosAnticipacion: _perfilId(json['minutos_anticipacion']),
      frecuenciaRecordatorio: json['frecuencia_recordatorio'] as String,
      horaSilencioInicio: json['hora_silencio_inicio'] as String?,
      horaSilencioFin: json['hora_silencio_fin'] as String?,
      estadoPreferencia: json['estado_preferencia'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _perfilDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_preferencia': idPreferencia,
      'id_ciudadano': idCiudadano,
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
      'frecuencia_recordatorio': frecuenciaRecordatorio,
      'hora_silencio_inicio': horaSilencioInicio,
      'hora_silencio_fin': horaSilencioFin,
      'estado_preferencia': estadoPreferencia,
      'created_at': _perfilDateJson(createdAt),
      'updated_at': _perfilDateJson(updatedAt),
      'deleted_at': _perfilDateJson(deletedAt),
    };
  }
}

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************

int _perfilId(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException('El servidor devolvió un valor entero inválido.');
}

DateTime? _perfilDate(dynamic value) {
  if (value == null) return null;

  return DateTime.parse(value as String);
}

String? _perfilDateJson(DateTime? value) {
  return value?.toUtc().toIso8601String();
}
