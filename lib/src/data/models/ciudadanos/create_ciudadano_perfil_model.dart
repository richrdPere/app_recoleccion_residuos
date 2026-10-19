// *********************************************************
// REQUEST - CREAR PERFIL CIUDADANO
// *********************************************************

class CreateCiudadanoPerfilRequest {
  final bool aceptaTratamientoDatos;
  final String versionConsentimiento;
  final String origenRegistro;
  final String? observacion;

  const CreateCiudadanoPerfilRequest({
    required this.aceptaTratamientoDatos,
    required this.versionConsentimiento,
    this.origenRegistro = 'APP',
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'acepta_tratamiento_datos': aceptaTratamientoDatos,
      'version_consentimiento': versionConsentimiento.trim(),
      'origen_registro': origenRegistro.trim().toUpperCase(),
      'observacion': observacion?.trim(),
    };
  }
}

// *********************************************************
// DATA - PERFIL CIUDADANO CREADO
// *********************************************************

class CreateCiudadanoPerfilDataModel {
  final int idCiudadano;
  final int idUsuario;
  final bool celularVerificado;
  final bool aceptaTratamientoDatos;
  final DateTime? fechaConsentimiento;
  final String? versionConsentimiento;
  final String origenRegistro;
  final String estadoCiudadano;
  final DateTime? fechaActivacion;
  final String? observacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreateCiudadanoPerfilDataModel({
    required this.idCiudadano,
    required this.idUsuario,
    required this.celularVerificado,
    required this.aceptaTratamientoDatos,
    this.fechaConsentimiento,
    this.versionConsentimiento,
    required this.origenRegistro,
    required this.estadoCiudadano,
    this.fechaActivacion,
    this.observacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateCiudadanoPerfilDataModel.fromJson(Map<String, dynamic> json) {
    return CreateCiudadanoPerfilDataModel(
      idCiudadano: _parseCiudadanoId(json['id_ciudadano']),
      idUsuario: _parseCiudadanoId(json['id_usuario']),
      celularVerificado: json['celular_verificado'] as bool,
      aceptaTratamientoDatos: json['acepta_tratamiento_datos'] as bool,
      fechaConsentimiento: _parseNullableDate(json['fecha_consentimiento']),
      versionConsentimiento: json['version_consentimiento'] as String?,
      origenRegistro: json['origen_registro'] as String,
      estadoCiudadano: json['estado_ciudadano'] as String,
      fechaActivacion: _parseNullableDate(json['fecha_activacion']),
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ciudadano': idCiudadano,
      'id_usuario': idUsuario,
      'celular_verificado': celularVerificado,
      'acepta_tratamiento_datos': aceptaTratamientoDatos,
      'fecha_consentimiento': fechaConsentimiento?.toUtc().toIso8601String(),
      'version_consentimiento': versionConsentimiento,
      'origen_registro': origenRegistro,
      'estado_ciudadano': estadoCiudadano,
      'fecha_activacion': fechaActivacion?.toUtc().toIso8601String(),
      'observacion': observacion,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************

int _parseCiudadanoId(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException(
    'El servidor devolvió un identificador de ciudadano inválido.',
  );
}

DateTime? _parseNullableDate(dynamic value) {
  if (value == null) return null;

  return DateTime.parse(value as String);
}
