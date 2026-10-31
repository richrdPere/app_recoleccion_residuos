// *********************************************************
// DATA - INCIDENCIAS PAGINADAS
// *********************************************************
class IncidenciasPaginadasDataModel {
  final List<IncidenciaListadoModel> items;
  final IncidenciasPaginationModel pagination;

  const IncidenciasPaginadasDataModel({
    required this.items,
    required this.pagination,
  });

  factory IncidenciasPaginadasDataModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    if (rawItems is! List) {
      throw const FormatException(
        'El listado de incidencias no tiene un formato válido.',
      );
    }

    return IncidenciasPaginadasDataModel(
      items: rawItems
          .map(
            (item) => IncidenciaListadoModel.fromJson(_readMap(item, 'items')),
          )
          .toList(),
      pagination: IncidenciasPaginationModel.fromJson(
        _readMap(json['pagination'], 'pagination'),
      ),
    );
  }
}

// *********************************************************
// ITEM - INCIDENCIA
// *********************************************************
class IncidenciaListadoModel {
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

  final IncidenciaUsuarioResumenModel? reportante;
  final IncidenciaUsuarioResumenModel? responsable;

  final IncidenciaZonaResumenModel? zona;
  final IncidenciaRutaResumenModel? ruta;
  final IncidenciaRecorridoResumenModel? recorrido;

  const IncidenciaListadoModel({
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

  factory IncidenciaListadoModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaListadoModel(
      idIncidencia: _readInt(json['id_incidencia'], 'id_incidencia'),
      idUsuarioReporte: _readInt(
        json['id_usuario_reporte'],
        'id_usuario_reporte',
      ),
      idResponsable: _readNullableInt(json['id_responsable'], 'id_responsable'),
      idRecorrido: _readNullableInt(json['id_recorrido'], 'id_recorrido'),
      idZona: _readNullableInt(json['id_zona'], 'id_zona'),
      idRuta: _readNullableInt(json['id_ruta'], 'id_ruta'),
      tipo: json['tipo'] as String,
      prioridad: json['prioridad'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      origen: json['origen'] as String,
      estadoIncidencia: json['estado_incidencia'] as String,
      fechaReporte: json['fecha_reporte'] as String,
      fechaResolucion: json['fecha_resolucion'] as String?,
      detalleResolucion: json['detalle_resolucion'] as String?,
      latitud: _readNullableDouble(json['latitud'], 'latitud'),
      longitud: _readNullableDouble(json['longitud'], 'longitud'),
      precisionUbicacion: _readNullableDouble(
        json['precision_ubicacion'],
        'precision_ubicacion',
      ),
      direccionReferencia: json['direccion_referencia'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
      reportante: json['reportante'] == null
          ? null
          : IncidenciaUsuarioResumenModel.fromJson(
              _readMap(json['reportante'], 'reportante'),
            ),
      responsable: json['responsable'] == null
          ? null
          : IncidenciaUsuarioResumenModel.fromJson(
              _readMap(json['responsable'], 'responsable'),
            ),
      zona: json['zona'] == null
          ? null
          : IncidenciaZonaResumenModel.fromJson(_readMap(json['zona'], 'zona')),
      ruta: json['ruta'] == null
          ? null
          : IncidenciaRutaResumenModel.fromJson(_readMap(json['ruta'], 'ruta')),
      recorrido: json['recorrido'] == null
          ? null
          : IncidenciaRecorridoResumenModel.fromJson(
              _readMap(json['recorrido'], 'recorrido'),
            ),
    );
  }
}

// *********************************************************
// PAGINACIÓN
// *********************************************************
class IncidenciasPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const IncidenciasPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory IncidenciasPaginationModel.fromJson(Map<String, dynamic> json) {
    return IncidenciasPaginationModel(
      total: _readInt(json['total'], 'total'),
      page: _readInt(json['page'], 'page'),
      limit: _readInt(json['limit'], 'limit'),
      totalPages: _readInt(json['total_pages'], 'total_pages'),
    );
  }
}

// *********************************************************
// USUARIO RESUMIDO
// *********************************************************
class IncidenciaUsuarioResumenModel {
  final int idUsuario;
  final String username;

  const IncidenciaUsuarioResumenModel({
    required this.idUsuario,
    required this.username,
  });

  factory IncidenciaUsuarioResumenModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaUsuarioResumenModel(
      idUsuario: _readInt(json['id_usuario'], 'id_usuario'),
      username: json['username'] as String,
    );
  }
}

// *********************************************************
// ZONA RESUMIDA
// *********************************************************

class IncidenciaZonaResumenModel {
  final int idZona;
  final String codigo;
  final String nombre;

  const IncidenciaZonaResumenModel({
    required this.idZona,
    required this.codigo,
    required this.nombre,
  });

  factory IncidenciaZonaResumenModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaZonaResumenModel(
      idZona: _readInt(json['id_zona'], 'id_zona'),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}

// *********************************************************
// RUTA RESUMIDA
// *********************************************************

class IncidenciaRutaResumenModel {
  final int idRuta;
  final String codigo;
  final String nombre;

  const IncidenciaRutaResumenModel({
    required this.idRuta,
    required this.codigo,
    required this.nombre,
  });

  factory IncidenciaRutaResumenModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaRutaResumenModel(
      idRuta: _readInt(json['id_ruta'], 'id_ruta'),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}

// *********************************************************
// RECORRIDO RESUMIDO
// *********************************************************

class IncidenciaRecorridoResumenModel {
  final int idRecorrido;
  final String estadoRecorrido;

  const IncidenciaRecorridoResumenModel({
    required this.idRecorrido,
    required this.estadoRecorrido,
  });

  factory IncidenciaRecorridoResumenModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaRecorridoResumenModel(
      idRecorrido: _readInt(json['id_recorrido'], 'id_recorrido'),
      estadoRecorrido: json['estado_recorrido'] as String,
    );
  }
}

// *********************************************************
// UTILIDADES PRIVADAS DE PARSEO
// *********************************************************

Map<String, dynamic> _readMap(dynamic value, String field) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw FormatException('El campo "$field" debe ser un objeto.');
}

int _readInt(dynamic value, String field) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    final parsed = int.tryParse(value.trim());

    if (parsed != null) {
      return parsed;
    }
  }

  throw FormatException('El campo "$field" debe ser un entero válido.');
}

int? _readNullableInt(dynamic value, String field) {
  return value == null ? null : _readInt(value, field);
}

double? _readNullableDouble(dynamic value, String field) {
  if (value == null) {
    return null;
  }

  final parsed = value is num
      ? value.toDouble()
      : value is String
      ? double.tryParse(value.trim())
      : null;

  if (parsed == null || !parsed.isFinite) {
    throw FormatException('El campo "$field" debe ser un decimal válido.');
  }

  return parsed;
}

// *********************************************************
// MODELO - ARCHIVO DE INCIDENCIA
// *********************************************************

class IncidenciaArchivoModel {
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

  const IncidenciaArchivoModel({
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
  });

  factory IncidenciaArchivoModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaArchivoModel(
      idIncidenciaArchivo: _readInt(
        json['id_incidencia_archivo'],
        'id_incidencia_archivo',
      ),
      idIncidencia: _readInt(json['id_incidencia'], 'id_incidencia'),
      idUsuarioCarga: _readInt(json['id_usuario_carga'], 'id_usuario_carga'),
      tipoArchivo: json['tipo_archivo'] as String,
      nombreOriginal: json['nombre_original'] as String,
      mimeType: json['mime_type'] as String,
      tamanioBytes: _readInt(json['tamanio_bytes'], 'tamanio_bytes'),
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
    );
  }
}

// *********************************************************
// FILTROS - INCIDENCIAS PAGINADAS
// *********************************************************

class IncidenciasPaginadasFilters {
  final int page;
  final int limit;

  final String? search;

  final String? tipo;
  final String? prioridad;
  final String? origen;
  final String? estadoIncidencia;

  /// Habilitación administrativa.
  final bool? estado;

  final int? idUsuarioReporte;
  final int? idResponsable;
  final int? idRecorrido;
  final int? idZona;
  final int? idRuta;

  /// YYYY-MM-DD o timestamp ISO con zona horaria.
  final String? fechaDesde;
  final String? fechaHasta;

  final String sortBy;
  final String sortOrder;

  const IncidenciasPaginadasFilters({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.tipo,
    this.prioridad,
    this.origen,
    this.estadoIncidencia,
    this.estado,
    this.idUsuarioReporte,
    this.idResponsable,
    this.idRecorrido,
    this.idZona,
    this.idRuta,
    this.fechaDesde,
    this.fechaHasta,
    this.sortBy = 'fecha_reporte',
    this.sortOrder = 'DESC',
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    void addText(String key, String? value) {
      final normalized = value?.trim();

      if (normalized != null && normalized.isNotEmpty) {
        params[key] = normalized;
      }
    }

    void addId(String key, int? value) {
      if (value != null) {
        params[key] = value.toString();
      }
    }

    addText('search', search);
    addText('tipo', tipo);
    addText('prioridad', prioridad);
    addText('origen', origen);
    addText('estado_incidencia', estadoIncidencia);

    // Conserva explícitamente false.
    if (estado != null) {
      params['estado'] = estado.toString();
    }

    addId('id_usuario_reporte', idUsuarioReporte);
    addId('id_responsable', idResponsable);
    addId('id_recorrido', idRecorrido);
    addId('id_zona', idZona);
    addId('id_ruta', idRuta);

    addText('fecha_desde', fechaDesde);
    addText('fecha_hasta', fechaHasta);

    return params;
  }
}
