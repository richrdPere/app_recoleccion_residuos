// *********************************************************
// REQUEST - ACTUALIZAR DOMICILIO
// *********************************************************

class UpdateCiudadanoDomicilioRequest {
  final String nombreDomicilio;
  final String direccion;
  final String? referencia;

  final double latitud;
  final double longitud;
  final double? precisionUbicacion;
  final String origenUbicacion;

  final String? observacion;

  const UpdateCiudadanoDomicilioRequest({
    required this.nombreDomicilio,
    required this.direccion,
    this.referencia,
    required this.latitud,
    required this.longitud,
    this.precisionUbicacion,
    this.origenUbicacion = 'MAPA',
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_domicilio': nombreDomicilio.trim(),
      'direccion': direccion.trim(),
      'referencia': referencia?.trim(),
      'latitud': latitud,
      'longitud': longitud,
      'precision_ubicacion': precisionUbicacion,
      'origen_ubicacion': origenUbicacion.trim().toUpperCase(),
      'observacion': observacion?.trim(),
    };
  }
}

// *********************************************************
// DATA - DOMICILIO ACTUALIZADO
// *********************************************************

class UpdateCiudadanoDomicilioDataModel {
  final int idDomicilio;
  final int idCiudadano;
  final int? idZona;
  final int? idRuta;

  final String nombreDomicilio;
  final String direccion;
  final String? referencia;

  final double latitud;
  final double longitud;
  final double? precisionUbicacion;
  final String origenUbicacion;

  final bool esPrincipal;
  final bool ubicacionValidada;
  final DateTime? fechaValidacion;
  final int? idUsuarioValidacion;

  final String estadoDomicilio;
  final String? observacion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const UpdateCiudadanoDomicilioDataModel({
    required this.idDomicilio,
    required this.idCiudadano,
    this.idZona,
    this.idRuta,
    required this.nombreDomicilio,
    required this.direccion,
    this.referencia,
    required this.latitud,
    required this.longitud,
    this.precisionUbicacion,
    required this.origenUbicacion,
    required this.esPrincipal,
    required this.ubicacionValidada,
    this.fechaValidacion,
    this.idUsuarioValidacion,
    required this.estadoDomicilio,
    this.observacion,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory UpdateCiudadanoDomicilioDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UpdateCiudadanoDomicilioDataModel(
      idDomicilio: _updateDomicilioInt(json['id_domicilio']),
      idCiudadano: _updateDomicilioInt(json['id_ciudadano']),
      idZona: _updateDomicilioNullableInt(json['id_zona']),
      idRuta: _updateDomicilioNullableInt(json['id_ruta']),
      nombreDomicilio: json['nombre_domicilio'] as String,
      direccion: json['direccion'] as String,
      referencia: json['referencia'] as String?,
      latitud: _updateDomicilioDouble(json['latitud']),
      longitud: _updateDomicilioDouble(json['longitud']),
      precisionUbicacion: json['precision_ubicacion'] == null
          ? null
          : _updateDomicilioDouble(json['precision_ubicacion']),
      origenUbicacion: json['origen_ubicacion'] as String,
      esPrincipal: json['es_principal'] as bool,
      ubicacionValidada: json['ubicacion_validada'] as bool,
      fechaValidacion: _updateDomicilioDate(json['fecha_validacion']),
      idUsuarioValidacion: _updateDomicilioNullableInt(
        json['id_usuario_validacion'],
      ),
      estadoDomicilio: json['estado_domicilio'] as String,
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _updateDomicilioDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_domicilio': idDomicilio,
      'id_ciudadano': idCiudadano,
      'id_zona': idZona,
      'id_ruta': idRuta,
      'nombre_domicilio': nombreDomicilio,
      'direccion': direccion,
      'referencia': referencia,
      'latitud': latitud,
      'longitud': longitud,
      'precision_ubicacion': precisionUbicacion,
      'origen_ubicacion': origenUbicacion,
      'es_principal': esPrincipal,
      'ubicacion_validada': ubicacionValidada,
      'fecha_validacion': fechaValidacion?.toUtc().toIso8601String(),
      'id_usuario_validacion': idUsuarioValidacion,
      'estado_domicilio': estadoDomicilio,
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

int _updateDomicilioInt(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException(
    'El servidor devolvió un identificador inválido.',
  );
}

int? _updateDomicilioNullableInt(dynamic value) {
  return value == null ? null : _updateDomicilioInt(value);
}

double _updateDomicilioDouble(dynamic value) {
  final double? parsed;

  if (value is num) {
    parsed = value.toDouble();
  } else if (value is String) {
    parsed = double.tryParse(value);
  } else {
    parsed = null;
  }

  if (parsed == null || !parsed.isFinite) {
    throw const FormatException(
      'El servidor devolvió un valor decimal inválido.',
    );
  }

  return parsed;
}

DateTime? _updateDomicilioDate(dynamic value) {
  return value == null ? null : DateTime.parse(value as String);
}
