// *********************************************************
// DOMICILIO
// *********************************************************

class GetMisDomiciliosDataModel {
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

  final DomicilioZonaModel? zona;
  final DomicilioRutaModel? ruta;

  // Pendiente tipar cuando se conozca su respuesta no nula.
  final Map<String, dynamic>? usuarioValidacion;

  const GetMisDomiciliosDataModel({
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
    this.zona,
    this.ruta,
    this.usuarioValidacion,
  });

  factory GetMisDomiciliosDataModel.fromJson(Map<String, dynamic> json) {
    return GetMisDomiciliosDataModel(
      idDomicilio: _domiciliosInt(json['id_domicilio']),
      idCiudadano: _domiciliosInt(json['id_ciudadano']),
      idZona: _domiciliosNullableInt(json['id_zona']),
      idRuta: _domiciliosNullableInt(json['id_ruta']),
      nombreDomicilio: json['nombre_domicilio'] as String,
      direccion: json['direccion'] as String,
      referencia: json['referencia'] as String?,
      latitud: _domiciliosDouble(json['latitud']),
      longitud: _domiciliosDouble(json['longitud']),
      precisionUbicacion: _domiciliosNullableDouble(
        json['precision_ubicacion'],
      ),
      origenUbicacion: json['origen_ubicacion'] as String,
      esPrincipal: json['es_principal'] as bool,
      ubicacionValidada: json['ubicacion_validada'] as bool,
      fechaValidacion: _domiciliosDate(json['fecha_validacion']),
      idUsuarioValidacion: _domiciliosNullableInt(
        json['id_usuario_validacion'],
      ),
      estadoDomicilio: json['estado_domicilio'] as String,
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _domiciliosDate(json['deleted_at']),
      zona: json['zona'] == null
          ? null
          : DomicilioZonaModel.fromJson(
              Map<String, dynamic>.from(json['zona'] as Map),
            ),
      ruta: json['ruta'] == null
          ? null
          : DomicilioRutaModel.fromJson(
              Map<String, dynamic>.from(json['ruta'] as Map),
            ),
      usuarioValidacion: json['usuario_validacion'] == null
          ? null
          : Map<String, dynamic>.from(json['usuario_validacion'] as Map),
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
      'fecha_validacion': _domiciliosDateJson(fechaValidacion),
      'id_usuario_validacion': idUsuarioValidacion,
      'estado_domicilio': estadoDomicilio,
      'observacion': observacion,
      'created_at': _domiciliosDateJson(createdAt),
      'updated_at': _domiciliosDateJson(updatedAt),
      'deleted_at': _domiciliosDateJson(deletedAt),
      'zona': zona?.toJson(),
      'ruta': ruta?.toJson(),
      'usuario_validacion': usuarioValidacion,
    };
  }
}

// *********************************************************
// ZONA
// *********************************************************

class DomicilioZonaModel {
  final int idZona;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String? color;

  // Conserva la geometría GeoJSON sin alterar sus coordenadas.
  final Map<String, dynamic>? poligonoGeojson;

  final double? centroLatitud;
  final double? centroLongitud;
  final bool estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const DomicilioZonaModel({
    required this.idZona,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.color,
    this.poligonoGeojson,
    this.centroLatitud,
    this.centroLongitud,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory DomicilioZonaModel.fromJson(Map<String, dynamic> json) {
    return DomicilioZonaModel(
      idZona: _domiciliosInt(json['id_zona']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String?,
      poligonoGeojson: json['poligono_geojson'] == null
          ? null
          : Map<String, dynamic>.from(json['poligono_geojson'] as Map),
      centroLatitud: _domiciliosNullableDouble(json['centro_latitud']),
      centroLongitud: _domiciliosNullableDouble(json['centro_longitud']),
      estado: json['estado'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _domiciliosDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_zona': idZona,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
      'poligono_geojson': poligonoGeojson,
      'centro_latitud': centroLatitud,
      'centro_longitud': centroLongitud,
      'estado': estado,
      'created_at': _domiciliosDateJson(createdAt),
      'updated_at': _domiciliosDateJson(updatedAt),
      'deleted_at': _domiciliosDateJson(deletedAt),
    };
  }
}

// *********************************************************
// RUTA
// *********************************************************

class DomicilioRutaModel {
  final int idRuta;
  final int idZona;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String? color;
  final String estadoRuta;
  final bool estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const DomicilioRutaModel({
    required this.idRuta,
    required this.idZona,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.color,
    required this.estadoRuta,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory DomicilioRutaModel.fromJson(Map<String, dynamic> json) {
    return DomicilioRutaModel(
      idRuta: _domiciliosInt(json['id_ruta']),
      idZona: _domiciliosInt(json['id_zona']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String?,
      estadoRuta: json['estado_ruta'] as String,
      estado: json['estado'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _domiciliosDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ruta': idRuta,
      'id_zona': idZona,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
      'estado_ruta': estadoRuta,
      'estado': estado,
      'created_at': _domiciliosDateJson(createdAt),
      'updated_at': _domiciliosDateJson(updatedAt),
      'deleted_at': _domiciliosDateJson(deletedAt),
    };
  }
}

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************

int _domiciliosInt(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException('El servidor devolvió un valor entero inválido.');
}

int? _domiciliosNullableInt(dynamic value) {
  return value == null ? null : _domiciliosInt(value);
}

double _domiciliosDouble(dynamic value) {
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

double? _domiciliosNullableDouble(dynamic value) {
  return value == null ? null : _domiciliosDouble(value);
}

DateTime? _domiciliosDate(dynamic value) {
  return value == null ? null : DateTime.parse(value as String);
}

String? _domiciliosDateJson(DateTime? value) {
  return value?.toUtc().toIso8601String();
}
