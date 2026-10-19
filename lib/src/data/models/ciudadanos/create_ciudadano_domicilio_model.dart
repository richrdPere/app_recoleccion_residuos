// *********************************************************
// REQUEST - REGISTRAR DOMICILIO
// *********************************************************

class CreateCiudadanoDomicilioRequest {
  final int idZona;
  final int idRuta;
  final String nombreDomicilio;
  final String direccion;
  final String? referencia;

  final double latitud;
  final double longitud;
  final double? precisionUbicacion;
  final String origenUbicacion;

  final bool esPrincipal;
  final String? observacion;

  const CreateCiudadanoDomicilioRequest({
    required this.idZona,
    required this.idRuta,
    required this.nombreDomicilio,
    required this.direccion,
    this.referencia,
    required this.latitud,
    required this.longitud,
    this.precisionUbicacion,
    this.origenUbicacion = 'MAPA',
    this.esPrincipal = false,
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_zona': idZona,
      'id_ruta': idRuta,
      'nombre_domicilio': nombreDomicilio.trim(),
      'direccion': direccion.trim(),
      'referencia': referencia?.trim(),
      'latitud': latitud,
      'longitud': longitud,
      'precision_ubicacion': precisionUbicacion,
      'origen_ubicacion': origenUbicacion.trim().toUpperCase(),
      'es_principal': esPrincipal,
      'observacion': observacion?.trim(),
    };
  }
}

// *********************************************************
// DATA - DOMICILIO REGISTRADO
// *********************************************************

class CreateCiudadanoDomicilioDataModel {
  final int idDomicilio;
  final int idCiudadano;
  final int idZona;
  final int idRuta;

  final String nombreDomicilio;
  final String direccion;
  final String? referencia;

  final double latitud;
  final double longitud;
  final double? precisionUbicacion;
  final String origenUbicacion;
  final bool ubicacionValidada;

  final bool esPrincipal;
  final String estadoDomicilio;
  final String? observacion;

  final DateTime createdAt;
  final DateTime updatedAt;

  const CreateCiudadanoDomicilioDataModel({
    required this.idDomicilio,
    required this.idCiudadano,
    required this.idZona,
    required this.idRuta,
    required this.nombreDomicilio,
    required this.direccion,
    this.referencia,
    required this.latitud,
    required this.longitud,
    this.precisionUbicacion,
    required this.origenUbicacion,
    required this.ubicacionValidada,
    required this.esPrincipal,
    required this.estadoDomicilio,
    this.observacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateCiudadanoDomicilioDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateCiudadanoDomicilioDataModel(
      idDomicilio: _domicilioInt(json['id_domicilio']),
      idCiudadano: _domicilioInt(json['id_ciudadano']),
      idZona: _domicilioInt(json['id_zona']),
      idRuta: _domicilioInt(json['id_ruta']),
      nombreDomicilio: json['nombre_domicilio'] as String,
      direccion: json['direccion'] as String,
      referencia: json['referencia'] as String?,
      latitud: _domicilioDouble(json['latitud']),
      longitud: _domicilioDouble(json['longitud']),
      precisionUbicacion: json['precision_ubicacion'] == null
          ? null
          : _domicilioDouble(json['precision_ubicacion']),
      origenUbicacion: json['origen_ubicacion'] as String,
      ubicacionValidada: json['ubicacion_validada'] as bool,
      esPrincipal: json['es_principal'] as bool,
      estadoDomicilio: json['estado_domicilio'] as String,
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'ubicacion_validada': ubicacionValidada,
      'es_principal': esPrincipal,
      'estado_domicilio': estadoDomicilio,
      'observacion': observacion,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************

int _domicilioInt(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException(
    'El servidor devolvió un identificador de domicilio inválido.',
  );
}

double _domicilioDouble(dynamic value) {
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
      'El servidor devolvió un valor numérico de ubicación inválido.',
    );
  }

  return parsed;
}
