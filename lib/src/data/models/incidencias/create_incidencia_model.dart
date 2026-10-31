// *********************************************************
// ORIGEN PERMITIDO EN LA APLICACIÓN MÓVIL
// *********************************************************

enum IncidenciaOrigenMovil {
  ciudadana('APP_CIUDADANA'),
  operativa('APP_OPERATIVA');

  final String value;

  const IncidenciaOrigenMovil(this.value);
}

// *********************************************************
// REQUEST - CREAR INCIDENCIA
// *********************************************************

class CreateIncidenciaRequest {
  final String tipo;
  final String prioridad;
  final String titulo;
  final String descripcion;

  final IncidenciaOrigenMovil origen;

  final int? idRecorrido;
  final int? idZona;
  final int? idRuta;

  final double? latitud;
  final double? longitud;
  final double? precisionUbicacion;

  final String? direccionReferencia;

  const CreateIncidenciaRequest({
    required this.tipo,
    this.prioridad = 'MEDIA',
    required this.titulo,
    required this.descripcion,
    required this.origen,
    this.idRecorrido,
    this.idZona,
    this.idRuta,
    this.latitud,
    this.longitud,
    this.precisionUbicacion,
    this.direccionReferencia,
  });

  Map<String, dynamic> toJson() {
    final direccion = direccionReferencia?.trim();

    return {
      'tipo': tipo,
      'prioridad': prioridad,
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'origen': origen.value,

      if (idRecorrido != null) 'id_recorrido': idRecorrido.toString(),

      if (idZona != null) 'id_zona': idZona.toString(),

      if (idRuta != null) 'id_ruta': idRuta.toString(),

      if (latitud != null) 'latitud': latitud,

      if (longitud != null) 'longitud': longitud,

      if (precisionUbicacion != null) 'precision_ubicacion': precisionUbicacion,

      if (direccion != null && direccion.isNotEmpty)
        'direccion_referencia': direccion,
    };
  }
}

// *********************************************************
// DATA - INCIDENCIA CREADA
// Modelo independiente del listado y del detalle.
// *********************************************************

class CreateIncidenciaDataModel {
  final int idIncidencia;
  final int idUsuarioReporte;
  final int? idResponsable;

  final int? idRecorrido;
  final int? idZona;
  final int? idRuta;

  final String tipo;
  final String prioridad;
  final String titulo;
  final String descripcion;

  final String origen;
  final String estadoIncidencia;

  final String fechaReporte;
  final String? fechaResolucion;
  final String? detalleResolucion;

  final double? latitud;
  final double? longitud;
  final double? precisionUbicacion;

  final String? direccionReferencia;

  final bool estado;

  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  final CreateIncidenciaUsuarioModel? reportante;
  final CreateIncidenciaUsuarioModel? responsable;
  final CreateIncidenciaZonaModel? zona;
  final CreateIncidenciaRutaModel? ruta;
  final CreateIncidenciaRecorridoModel? recorrido;

  const CreateIncidenciaDataModel({
    required this.idIncidencia,
    required this.idUsuarioReporte,
    required this.idResponsable,
    required this.idRecorrido,
    required this.idZona,
    required this.idRuta,
    required this.tipo,
    required this.prioridad,
    required this.titulo,
    required this.descripcion,
    required this.origen,
    required this.estadoIncidencia,
    required this.fechaReporte,
    required this.fechaResolucion,
    required this.detalleResolucion,
    required this.latitud,
    required this.longitud,
    required this.precisionUbicacion,
    required this.direccionReferencia,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.reportante,
    required this.responsable,
    required this.zona,
    required this.ruta,
    required this.recorrido,
  });

  factory CreateIncidenciaDataModel.fromJson(Map<String, dynamic> json) {
    final archivos = json['archivos'];

    // Este endpoint crea el reporte sin adjuntos.
    // Las evidencias se registran mediante su propio service.
    if (archivos is! List || archivos.isNotEmpty) {
      throw const FormatException(
        'La creación debe devolver una incidencia sin archivos adjuntos.',
      );
    }

    return CreateIncidenciaDataModel(
      idIncidencia: _readInt(json['id_incidencia']),
      idUsuarioReporte: _readInt(json['id_usuario_reporte']),
      idResponsable: _readNullableInt(json['id_responsable']),
      idRecorrido: _readNullableInt(json['id_recorrido']),
      idZona: _readNullableInt(json['id_zona']),
      idRuta: _readNullableInt(json['id_ruta']),
      tipo: json['tipo'] as String,
      prioridad: json['prioridad'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      origen: json['origen'] as String,
      estadoIncidencia: json['estado_incidencia'] as String,
      fechaReporte: json['fecha_reporte'] as String,
      fechaResolucion: json['fecha_resolucion'] as String?,
      detalleResolucion: json['detalle_resolucion'] as String?,
      latitud: _readNullableDouble(json['latitud']),
      longitud: _readNullableDouble(json['longitud']),
      precisionUbicacion: _readNullableDouble(json['precision_ubicacion']),
      direccionReferencia: json['direccion_referencia'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
      reportante: json['reportante'] == null
          ? null
          : CreateIncidenciaUsuarioModel.fromJson(_readMap(json['reportante'])),
      responsable: json['responsable'] == null
          ? null
          : CreateIncidenciaUsuarioModel.fromJson(
              _readMap(json['responsable']),
            ),
      zona: json['zona'] == null
          ? null
          : CreateIncidenciaZonaModel.fromJson(_readMap(json['zona'])),
      ruta: json['ruta'] == null
          ? null
          : CreateIncidenciaRutaModel.fromJson(_readMap(json['ruta'])),
      recorrido: json['recorrido'] == null
          ? null
          : CreateIncidenciaRecorridoModel.fromJson(
              _readMap(json['recorrido']),
            ),
    );
  }

  // La respuesta actual de creación siempre incluye archivos: [].
  List<Object> get archivos => const [];
}

// *********************************************************
// ASOCIACIONES DE LA RESPUESTA DE CREACIÓN
// *********************************************************

class CreateIncidenciaUsuarioModel {
  final int idUsuario;
  final String username;

  const CreateIncidenciaUsuarioModel({
    required this.idUsuario,
    required this.username,
  });

  factory CreateIncidenciaUsuarioModel.fromJson(Map<String, dynamic> json) {
    return CreateIncidenciaUsuarioModel(
      idUsuario: _readInt(json['id_usuario']),
      username: json['username'] as String,
    );
  }
}

class CreateIncidenciaZonaModel {
  final int idZona;
  final String codigo;
  final String nombre;

  const CreateIncidenciaZonaModel({
    required this.idZona,
    required this.codigo,
    required this.nombre,
  });

  factory CreateIncidenciaZonaModel.fromJson(Map<String, dynamic> json) {
    return CreateIncidenciaZonaModel(
      idZona: _readInt(json['id_zona']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}

class CreateIncidenciaRutaModel {
  final int idRuta;
  final String codigo;
  final String nombre;

  const CreateIncidenciaRutaModel({
    required this.idRuta,
    required this.codigo,
    required this.nombre,
  });

  factory CreateIncidenciaRutaModel.fromJson(Map<String, dynamic> json) {
    return CreateIncidenciaRutaModel(
      idRuta: _readInt(json['id_ruta']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}

class CreateIncidenciaRecorridoModel {
  final int idRecorrido;
  final String estadoRecorrido;

  const CreateIncidenciaRecorridoModel({
    required this.idRecorrido,
    required this.estadoRecorrido,
  });

  factory CreateIncidenciaRecorridoModel.fromJson(Map<String, dynamic> json) {
    return CreateIncidenciaRecorridoModel(
      idRecorrido: _readInt(json['id_recorrido']),
      estadoRecorrido: json['estado_recorrido'] as String,
    );
  }
}

// *********************************************************
// PARSEO PRIVADO
// *********************************************************

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw const FormatException('Se esperaba un objeto JSON.');
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    final parsed = int.tryParse(value.trim());

    if (parsed != null) {
      return parsed;
    }
  }

  throw const FormatException('Se esperaba un entero válido.');
}

int? _readNullableInt(dynamic value) {
  return value == null ? null : _readInt(value);
}

double? _readNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  final parsed = value is num
      ? value.toDouble()
      : value is String
      ? double.tryParse(value.trim())
      : null;

  if (parsed == null || !parsed.isFinite) {
    throw const FormatException('Se esperaba un decimal válido.');
  }

  return parsed;
}
