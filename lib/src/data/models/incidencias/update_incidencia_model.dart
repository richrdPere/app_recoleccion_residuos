// *********************************************************
// REQUEST - ACTUALIZAR INCIDENCIA
// *********************************************************

class UpdateIncidenciaRequest {
  final String? tipo;
  final String? prioridad;
  final String? titulo;
  final String? descripcion;

  final double? latitud;
  final double? longitud;
  final double? precisionUbicacion;

  final String? direccionReferencia;

  const UpdateIncidenciaRequest({
    this.tipo,
    this.prioridad,
    this.titulo,
    this.descripcion,
    this.latitud,
    this.longitud,
    this.precisionUbicacion,
    this.direccionReferencia,
  });

  Map<String, dynamic> toJson() {
    return {
      if (tipo != null) 'tipo': tipo,

      if (prioridad != null) 'prioridad': prioridad,

      if (titulo != null) 'titulo': titulo!.trim(),

      if (descripcion != null) 'descripcion': descripcion!.trim(),

      if (latitud != null) 'latitud': latitud,

      if (longitud != null) 'longitud': longitud,

      if (precisionUbicacion != null) 'precision_ubicacion': precisionUbicacion,

      if (direccionReferencia != null)
        'direccion_referencia': direccionReferencia!.trim(),
    };
  }
}

// *********************************************************
// DATA - INCIDENCIA ACTUALIZADA
// *********************************************************

class UpdateIncidenciaDataModel {
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

  final UpdateIncidenciaUsuarioModel? reportante;
  final UpdateIncidenciaUsuarioModel? responsable;
  final UpdateIncidenciaZonaModel? zona;
  final UpdateIncidenciaRutaModel? ruta;
  final UpdateIncidenciaRecorridoModel? recorrido;

  final List<UpdateIncidenciaArchivoModel> archivos;

  const UpdateIncidenciaDataModel({
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
    required this.archivos,
  });

  factory UpdateIncidenciaDataModel.fromJson(Map<String, dynamic> json) {
    final rawArchivos = json['archivos'];

    if (rawArchivos is! List) {
      throw const FormatException(
        'Los archivos de la incidencia deben ser una lista.',
      );
    }

    return UpdateIncidenciaDataModel(
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
      reportante: _readOptional(
        json['reportante'],
        UpdateIncidenciaUsuarioModel.fromJson,
      ),
      responsable: _readOptional(
        json['responsable'],
        UpdateIncidenciaUsuarioModel.fromJson,
      ),
      zona: _readOptional(json['zona'], UpdateIncidenciaZonaModel.fromJson),
      ruta: _readOptional(json['ruta'], UpdateIncidenciaRutaModel.fromJson),
      recorrido: _readOptional(
        json['recorrido'],
        UpdateIncidenciaRecorridoModel.fromJson,
      ),
      archivos: rawArchivos
          .map((item) => UpdateIncidenciaArchivoModel.fromJson(_readMap(item)))
          .toList(),
    );
  }
}

// *********************************************************
// USUARIO
// *********************************************************

class UpdateIncidenciaUsuarioModel {
  final int idUsuario;
  final String username;

  const UpdateIncidenciaUsuarioModel({
    required this.idUsuario,
    required this.username,
  });

  factory UpdateIncidenciaUsuarioModel.fromJson(Map<String, dynamic> json) {
    return UpdateIncidenciaUsuarioModel(
      idUsuario: _readInt(json['id_usuario']),
      username: json['username'] as String,
    );
  }
}

// *********************************************************
// ZONA
// *********************************************************

class UpdateIncidenciaZonaModel {
  final int idZona;
  final String codigo;
  final String nombre;

  const UpdateIncidenciaZonaModel({
    required this.idZona,
    required this.codigo,
    required this.nombre,
  });

  factory UpdateIncidenciaZonaModel.fromJson(Map<String, dynamic> json) {
    return UpdateIncidenciaZonaModel(
      idZona: _readInt(json['id_zona']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}

// *********************************************************
// RUTA
// *********************************************************

class UpdateIncidenciaRutaModel {
  final int idRuta;
  final String codigo;
  final String nombre;

  const UpdateIncidenciaRutaModel({
    required this.idRuta,
    required this.codigo,
    required this.nombre,
  });

  factory UpdateIncidenciaRutaModel.fromJson(Map<String, dynamic> json) {
    return UpdateIncidenciaRutaModel(
      idRuta: _readInt(json['id_ruta']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}

// *********************************************************
// RECORRIDO
// *********************************************************

class UpdateIncidenciaRecorridoModel {
  final int idRecorrido;
  final String estadoRecorrido;

  const UpdateIncidenciaRecorridoModel({
    required this.idRecorrido,
    required this.estadoRecorrido,
  });

  factory UpdateIncidenciaRecorridoModel.fromJson(Map<String, dynamic> json) {
    return UpdateIncidenciaRecorridoModel(
      idRecorrido: _readInt(json['id_recorrido']),
      estadoRecorrido: json['estado_recorrido'] as String,
    );
  }
}

// *********************************************************
// ARCHIVO
// *********************************************************

class UpdateIncidenciaArchivoModel {
  final int idIncidenciaArchivo;
  final int idIncidencia;
  final int idUsuarioCarga;

  final String tipoArchivo;
  final String nombreOriginal;
  final String mimeType;

  final int tamanioBytes;
  final String? descripcion;

  final bool estado;

  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const UpdateIncidenciaArchivoModel({
    required this.idIncidenciaArchivo,
    required this.idIncidencia,
    required this.idUsuarioCarga,
    required this.tipoArchivo,
    required this.nombreOriginal,
    required this.mimeType,
    required this.tamanioBytes,
    required this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory UpdateIncidenciaArchivoModel.fromJson(Map<String, dynamic> json) {
    return UpdateIncidenciaArchivoModel(
      idIncidenciaArchivo: _readInt(json['id_incidencia_archivo']),
      idIncidencia: _readInt(json['id_incidencia']),
      idUsuarioCarga: _readInt(json['id_usuario_carga']),
      tipoArchivo: json['tipo_archivo'] as String,
      nombreOriginal: json['nombre_original'] as String,
      mimeType: json['mime_type'] as String,
      tamanioBytes: _readInt(json['tamanio_bytes']),
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// UTILIDADES PRIVADAS DE PARSEO
// *********************************************************

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw const FormatException('Se esperaba un objeto JSON.');
}

T? _readOptional<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  return value == null ? null : parser(_readMap(value));
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
