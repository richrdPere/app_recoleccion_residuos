// *********************************************************
// REQUEST - ACTUALIZAR PERFIL CIUDADANO
// *********************************************************

class UpdateCiudadanoPerfilRequest {
  final bool aceptaTratamientoDatos;
  final String versionConsentimiento;
  final String? observacion;

  const UpdateCiudadanoPerfilRequest({
    required this.aceptaTratamientoDatos,
    required this.versionConsentimiento,
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'acepta_tratamiento_datos': aceptaTratamientoDatos,
      'version_consentimiento': versionConsentimiento.trim(),
      if (observacion != null) 'observacion': observacion!.trim(),
    };
  }
}

// *********************************************************
// DATA - PERFIL CIUDADANO ACTUALIZADO
// *********************************************************

class UpdateCiudadanoPerfilDataModel {
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

  const UpdateCiudadanoPerfilDataModel({
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
  });

  factory UpdateCiudadanoPerfilDataModel.fromJson(Map<String, dynamic> json) {
    return UpdateCiudadanoPerfilDataModel(
      idCiudadano: _updatePerfilInt(json['id_ciudadano']),
      idUsuario: _updatePerfilInt(json['id_usuario']),
      aceptaTratamientoDatos: json['acepta_tratamiento_datos'] as bool,
      fechaConsentimiento: _updatePerfilDate(json['fecha_consentimiento']),
      versionConsentimiento: json['version_consentimiento'] as String?,
      origenRegistro: json['origen_registro'] as String,
      celularVerificado: json['celular_verificado'] as bool,
      fechaVerificacionCelular: _updatePerfilDate(
        json['fecha_verificacion_celular'],
      ),
      estadoCiudadano: json['estado_ciudadano'] as String,
      fechaActivacion: _updatePerfilDate(json['fecha_activacion']),
      fechaDesactivacion: _updatePerfilDate(json['fecha_desactivacion']),
      motivoDesactivacion: json['motivo_desactivacion'] as String?,
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _updatePerfilDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ciudadano': idCiudadano,
      'id_usuario': idUsuario,
      'acepta_tratamiento_datos': aceptaTratamientoDatos,
      'fecha_consentimiento': fechaConsentimiento?.toUtc().toIso8601String(),
      'version_consentimiento': versionConsentimiento,
      'origen_registro': origenRegistro,
      'celular_verificado': celularVerificado,
      'fecha_verificacion_celular': fechaVerificacionCelular
          ?.toUtc()
          .toIso8601String(),
      'estado_ciudadano': estadoCiudadano,
      'fecha_activacion': fechaActivacion?.toUtc().toIso8601String(),
      'fecha_desactivacion': fechaDesactivacion?.toUtc().toIso8601String(),
      'motivo_desactivacion': motivoDesactivacion,
      'observacion': observacion,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************

int _updatePerfilInt(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException(
    'El servidor devolvió un identificador inválido.',
  );
}

DateTime? _updatePerfilDate(dynamic value) {
  if (value == null) return null;

  return DateTime.parse(value as String);
}
