// *********************************************************
// RESPUESTA: SERVICIO ACTIVO DEL DOMICILIO
// *********************************************************

class GetDomicilioServicioActivoDataModel {
  final DateTime fechaConsulta;
  final String situacion;

  final ServicioActivoDomicilioModel domicilio;
  final ServicioActivoRutaModel? ruta;
  final ServicioActivoDetalleModel? servicio;

  const GetDomicilioServicioActivoDataModel({
    required this.fechaConsulta,
    required this.situacion,
    required this.domicilio,
    this.ruta,
    this.servicio,
  });

  bool get sinRuta => situacion == 'SIN_RUTA';

  bool get sinServicioActivo => situacion == 'SIN_SERVICIO_ACTIVO';

  bool get enCurso => situacion == 'EN_CURSO';

  bool get pausado => situacion == 'PAUSADO';

  bool get tieneServicioActivo => servicio != null && (enCurso || pausado);

  bool get tieneUbicacion => servicio?.ultimaUbicacion != null;

  factory GetDomicilioServicioActivoDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetDomicilioServicioActivoDataModel(
      fechaConsulta: _readDate(json['fecha_consulta'], 'fecha_consulta'),
      situacion: json['situacion'] as String,
      domicilio: ServicioActivoDomicilioModel.fromJson(
        _readMap(json['domicilio'], 'domicilio'),
      ),
      ruta: json['ruta'] == null
          ? null
          : ServicioActivoRutaModel.fromJson(_readMap(json['ruta'], 'ruta')),
      servicio: json['servicio'] == null
          ? null
          : ServicioActivoDetalleModel.fromJson(
              _readMap(json['servicio'], 'servicio'),
            ),
    );
  }
}

// *********************************************************
// DOMICILIO DEL CIUDADANO
// *********************************************************

class ServicioActivoDomicilioModel {
  final int idDomicilio;
  final String nombre;
  final double? latitud;
  final double? longitud;

  const ServicioActivoDomicilioModel({
    required this.idDomicilio,
    required this.nombre,
    this.latitud,
    this.longitud,
  });

  factory ServicioActivoDomicilioModel.fromJson(Map<String, dynamic> json) {
    return ServicioActivoDomicilioModel(
      idDomicilio: _readInt(json['id_domicilio'], 'id_domicilio'),
      nombre: json['nombre'] as String,
      latitud: _readNullableDouble(json['latitud'], 'latitud'),
      longitud: _readNullableDouble(json['longitud'], 'longitud'),
    );
  }
}

// *********************************************************
// RUTA DISPONIBLE
// *********************************************************

class ServicioActivoRutaModel {
  final int idRuta;
  final String codigo;
  final String nombre;
  final String? color;

  final int? idRutaVersion;
  final ServicioActivoLineStringModel? geometriaGeojson;
  final String? origenGeometria;

  const ServicioActivoRutaModel({
    required this.idRuta,
    required this.codigo,
    required this.nombre,
    this.color,
    this.idRutaVersion,
    this.geometriaGeojson,
    this.origenGeometria,
  });

  bool get geometriaDeProgramacion => origenGeometria == 'PROGRAMACION';

  bool get geometriaDeVersionVigente => origenGeometria == 'VERSION_VIGENTE';

  factory ServicioActivoRutaModel.fromJson(Map<String, dynamic> json) {
    return ServicioActivoRutaModel(
      idRuta: _readInt(json['id_ruta'], 'id_ruta'),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      color: json['color'] as String?,
      idRutaVersion: json['id_ruta_version'] == null
          ? null
          : _readInt(json['id_ruta_version'], 'id_ruta_version'),
      geometriaGeojson: json['geometria_geojson'] == null
          ? null
          : ServicioActivoLineStringModel.fromJson(
              _readMap(json['geometria_geojson'], 'geometria_geojson'),
            ),
      origenGeometria: json['origen_geometria'] as String?,
    );
  }
}

// *********************************************************
// GEOMETRÍA DE LA RUTA
// GeoJSON mantiene el orden [longitud, latitud].
// *********************************************************

class ServicioActivoLineStringModel {
  final String type;
  final List<List<double>> coordinates;

  const ServicioActivoLineStringModel._({
    required this.type,
    required this.coordinates,
  });

  factory ServicioActivoLineStringModel.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'LineString') {
      throw const FormatException(
        'La geometría de la ruta debe ser LineString.',
      );
    }

    final rawCoordinates = json['coordinates'];

    if (rawCoordinates is! List || rawCoordinates.length < 2) {
      throw const FormatException(
        'La ruta debe contener al menos dos posiciones.',
      );
    }

    final positions = <List<double>>[];

    for (final rawPosition in rawCoordinates) {
      if (rawPosition is! List || rawPosition.length < 2) {
        throw const FormatException('Una posición de la ruta no es válida.');
      }

      final position = rawPosition
          .map((value) => _readDouble(value, 'coordinates'))
          .toList(growable: false);

      final longitude = position[0];
      final latitude = position[1];

      if (longitude < -180 ||
          longitude > 180 ||
          latitude < -90 ||
          latitude > 90) {
        throw const FormatException(
          'Una coordenada de la ruta está fuera de rango.',
        );
      }

      positions.add(List<double>.unmodifiable(position));
    }

    return ServicioActivoLineStringModel._(
      type: 'LineString',
      coordinates: List<List<double>>.unmodifiable(positions),
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'coordinates': coordinates};
}

// *********************************************************
// SERVICIO ACTIVO
// Es null cuando no hay un recorrido activo.
// *********************************************************

class ServicioActivoDetalleModel {
  final int idRecorrido;
  final String estado;

  /// Fecha de calendario: no convertir de zona horaria.
  final String fechaProgramada;

  final String horaInicioProgramada;
  final String horaFinProgramada;

  final ServicioActivoUbicacionModel? ultimaUbicacion;

  const ServicioActivoDetalleModel({
    required this.idRecorrido,
    required this.estado,
    required this.fechaProgramada,
    required this.horaInicioProgramada,
    required this.horaFinProgramada,
    this.ultimaUbicacion,
  });

  bool get enCurso => estado == 'EN_CURSO';
  bool get pausado => estado == 'PAUSADO';

  factory ServicioActivoDetalleModel.fromJson(Map<String, dynamic> json) {
    return ServicioActivoDetalleModel(
      idRecorrido: _readInt(json['id_recorrido'], 'id_recorrido'),
      estado: json['estado'] as String,
      fechaProgramada: json['fecha_programada'] as String,
      horaInicioProgramada: json['hora_inicio_programada'] as String,
      horaFinProgramada: json['hora_fin_programada'] as String,
      ultimaUbicacion: json['ultima_ubicacion'] == null
          ? null
          : ServicioActivoUbicacionModel.fromJson(
              _readMap(json['ultima_ubicacion'], 'ultima_ubicacion'),
            ),
    );
  }
}

// *********************************************************
// ÚLTIMA UBICACIÓN DEL CAMIÓN
// *********************************************************

class ServicioActivoUbicacionModel {
  final double latitud;
  final double longitud;
  final double? rumbo;

  final DateTime? fechaDispositivo;
  final DateTime? fechaRecepcion;

  const ServicioActivoUbicacionModel({
    required this.latitud,
    required this.longitud,
    this.rumbo,
    this.fechaDispositivo,
    this.fechaRecepcion,
  });

  factory ServicioActivoUbicacionModel.fromJson(Map<String, dynamic> json) {
    final latitud = _readDouble(json['latitud'], 'latitud');
    final longitud = _readDouble(json['longitud'], 'longitud');

    if (latitud < -90 || latitud > 90 || longitud < -180 || longitud > 180) {
      throw const FormatException(
        'La ubicación del camión está fuera de rango.',
      );
    }

    return ServicioActivoUbicacionModel(
      latitud: latitud,
      longitud: longitud,
      rumbo: _readNullableDouble(json['rumbo'], 'rumbo'),
      fechaDispositivo: json['fecha_dispositivo'] == null
          ? null
          : _readDate(json['fecha_dispositivo'], 'fecha_dispositivo'),
      fechaRecepcion: json['fecha_recepcion'] == null
          ? null
          : _readDate(json['fecha_recepcion'], 'fecha_recepcion'),
    );
  }
}

// *********************************************************
// HELPERS PRIVADOS
// *********************************************************

Map<String, dynamic> _readMap(Object? value, String field) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw FormatException('El campo "$field" debe ser un objeto.');
}

int _readInt(Object? value, String field) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
  }

  throw FormatException('El campo "$field" debe ser un entero válido.');
}

double _readDouble(Object? value, String field) {
  final parsed = value is num
      ? value.toDouble()
      : value is String
      ? double.tryParse(value.trim())
      : null;

  if (parsed == null || !parsed.isFinite) {
    throw FormatException('El campo "$field" debe ser un número válido.');
  }

  return parsed;
}

double? _readNullableDouble(Object? value, String field) {
  return value == null ? null : _readDouble(value, field);
}

DateTime _readDate(Object? value, String field) {
  final parsed = value is String ? DateTime.tryParse(value) : null;

  if (parsed == null) {
    throw FormatException('El campo "$field" contiene una fecha inválida.');
  }

  return parsed;
}
