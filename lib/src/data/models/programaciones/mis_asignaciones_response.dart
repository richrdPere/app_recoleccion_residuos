// *********************************************************
// 1. FILTROS
// *********************************************************
class MisAsignacionesFilters {
  final int? page;
  final int? limit;
  final String? estadoAsignacion;
  final String? estadoProgramacion;
  final String? fechaDesde;
  final String? fechaHasta;

  const MisAsignacionesFilters({
    this.page,
    this.limit,
    this.estadoAsignacion,
    this.estadoProgramacion,
    this.fechaDesde,
    this.fechaHasta,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    void addValue(String key, Object? value) {
      if (value == null) return;

      final normalized = value.toString().trim();

      if (normalized.isNotEmpty) {
        params[key] = normalized;
      }
    }

    addValue('page', page);
    addValue('limit', limit);
    addValue('estado_asignacion', estadoAsignacion);
    addValue('estado_programacion', estadoProgramacion);
    addValue('fecha_desde', fechaDesde);
    addValue('fecha_hasta', fechaHasta);

    return params;
  }
}

// *********************************************************
// 2. DATOS DE MIS ASIGNACIONES
// *********************************************************
class MisAsignacionesDataModel {
  final List<MiAsignacionModel> items;
  final MisAsignacionesPaginationModel pagination;

  const MisAsignacionesDataModel({
    required this.items,
    required this.pagination,
  });

  factory MisAsignacionesDataModel.fromJson(Map<String, dynamic> json) {
    return MisAsignacionesDataModel(
      items: (json['items'] as List)
          .map(
            (item) => MiAsignacionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      pagination: MisAsignacionesPaginationModel.fromJson(
        Map<String, dynamic>.from(json['pagination'] as Map),
      ),
    );
  }
}

// *********************************************************
// 3. PAGINACIÓN
// *********************************************************
class MisAsignacionesPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const MisAsignacionesPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MisAsignacionesPaginationModel.fromJson(Map<String, dynamic> json) {
    return MisAsignacionesPaginationModel(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );
  }

  bool get hasNextPage => page < totalPages;
}

// *********************************************************
// 4. ASIGNACIÓN
// *********************************************************
class MiAsignacionModel {
  final int idProgramacionPersonal;
  final int idProgramacion;
  final int idPersonal;
  final String funcion;
  final bool esPrincipal;
  final String estadoAsignacion;
  final String? fechaRespuesta;
  final String? observacion;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final MiAsignacionProgramacionModel programacion;

  const MiAsignacionModel({
    required this.idProgramacionPersonal,
    required this.idProgramacion,
    required this.idPersonal,
    required this.funcion,
    required this.esPrincipal,
    required this.estadoAsignacion,
    required this.fechaRespuesta,
    required this.observacion,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.programacion,
  });

  factory MiAsignacionModel.fromJson(Map<String, dynamic> json) {
    return MiAsignacionModel(
      idProgramacionPersonal: (json['id_programacion_personal'] as num).toInt(),
      idProgramacion: (json['id_programacion'] as num).toInt(),
      idPersonal: (json['id_personal'] as num).toInt(),
      funcion: json['funcion'] as String,
      esPrincipal: json['es_principal'] as bool,
      estadoAsignacion: json['estado_asignacion'] as String,
      fechaRespuesta: json['fecha_respuesta'] as String?,
      observacion: json['observacion'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
      programacion: MiAsignacionProgramacionModel.fromJson(
        Map<String, dynamic>.from(json['programacion'] as Map),
      ),
    );
  }
}

// *********************************************************
// 5. PROGRAMACIÓN
// *********************************************************
class MiAsignacionProgramacionModel {
  final int idProgramacion;
  final int idRuta;
  final int idRutaVersion;
  final int idVehiculo;
  final int idUsuarioCreacion;
  final String fechaProgramada;
  final String horaInicioProgramada;
  final String horaFinProgramada;
  final String turno;
  final String estadoProgramacion;
  final String? observacion;
  final String? motivoCancelacion;
  final String? fechaCancelacion;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final MiAsignacionRutaModel ruta;
  final MiAsignacionRutaVersionModel versionRuta;
  final MiAsignacionVehiculoModel vehiculo;

  const MiAsignacionProgramacionModel({
    required this.idProgramacion,
    required this.idRuta,
    required this.idRutaVersion,
    required this.idVehiculo,
    required this.idUsuarioCreacion,
    required this.fechaProgramada,
    required this.horaInicioProgramada,
    required this.horaFinProgramada,
    required this.turno,
    required this.estadoProgramacion,
    required this.observacion,
    required this.motivoCancelacion,
    required this.fechaCancelacion,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.ruta,
    required this.versionRuta,
    required this.vehiculo,
  });

  factory MiAsignacionProgramacionModel.fromJson(Map<String, dynamic> json) {
    return MiAsignacionProgramacionModel(
      idProgramacion: (json['id_programacion'] as num).toInt(),
      idRuta: (json['id_ruta'] as num).toInt(),
      idRutaVersion: (json['id_ruta_version'] as num).toInt(),
      idVehiculo: (json['id_vehiculo'] as num).toInt(),
      idUsuarioCreacion: (json['id_usuario_creacion'] as num).toInt(),
      fechaProgramada: json['fecha_programada'] as String,
      horaInicioProgramada: json['hora_inicio_programada'] as String,
      horaFinProgramada: json['hora_fin_programada'] as String,
      turno: json['turno'] as String,
      estadoProgramacion: json['estado_programacion'] as String,
      observacion: json['observacion'] as String?,
      motivoCancelacion: json['motivo_cancelacion'] as String?,
      fechaCancelacion: json['fecha_cancelacion'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
      ruta: MiAsignacionRutaModel.fromJson(
        Map<String, dynamic>.from(json['ruta'] as Map),
      ),
      versionRuta: MiAsignacionRutaVersionModel.fromJson(
        Map<String, dynamic>.from(json['version_ruta'] as Map),
      ),
      vehiculo: MiAsignacionVehiculoModel.fromJson(
        Map<String, dynamic>.from(json['vehiculo'] as Map),
      ),
    );
  }
}

// *********************************************************
// 6. RUTA
// *********************************************************
class MiAsignacionRutaModel {
  final int idRuta;
  final int idZona;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String color;
  final String estadoRuta;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const MiAsignacionRutaModel({
    required this.idRuta,
    required this.idZona,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.color,
    required this.estadoRuta,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory MiAsignacionRutaModel.fromJson(Map<String, dynamic> json) {
    return MiAsignacionRutaModel(
      idRuta: (json['id_ruta'] as num).toInt(),
      idZona: (json['id_zona'] as num).toInt(),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String,
      estadoRuta: json['estado_ruta'] as String,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// 7. GEOMETRÍA DE RUTA
// *********************************************************
class MiAsignacionLineStringModel {
  final String type;

  // GeoJSON: cada posición contiene [longitud, latitud].
  final List<List<double>> coordinates;

  const MiAsignacionLineStringModel({
    required this.type,
    required this.coordinates,
  });

  factory MiAsignacionLineStringModel.fromJson(Map<String, dynamic> json) {
    return MiAsignacionLineStringModel(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List)
          .map(
            (position) => (position as List)
                .map((value) => (value as num).toDouble())
                .toList(),
          )
          .toList(),
    );
  }
}

// *********************************************************
// 8. VERSIÓN DE RUTA
// *********************************************************
class MiAsignacionRutaVersionModel {
  final int idRutaVersion;
  final int idRuta;
  final int numeroVersion;
  final MiAsignacionLineStringModel geometriaGeojson;
  final double distanciaEstimadaKm;
  final int duracionEstimadaMin;
  final String fechaVigenciaDesde;
  final String? fechaVigenciaHasta;
  final bool vigente;
  final String? observacion;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const MiAsignacionRutaVersionModel({
    required this.idRutaVersion,
    required this.idRuta,
    required this.numeroVersion,
    required this.geometriaGeojson,
    required this.distanciaEstimadaKm,
    required this.duracionEstimadaMin,
    required this.fechaVigenciaDesde,
    required this.fechaVigenciaHasta,
    required this.vigente,
    required this.observacion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory MiAsignacionRutaVersionModel.fromJson(Map<String, dynamic> json) {
    return MiAsignacionRutaVersionModel(
      idRutaVersion: (json['id_ruta_version'] as num).toInt(),
      idRuta: (json['id_ruta'] as num).toInt(),
      numeroVersion: (json['numero_version'] as num).toInt(),
      geometriaGeojson: MiAsignacionLineStringModel.fromJson(
        Map<String, dynamic>.from(json['geometria_geojson'] as Map),
      ),
      distanciaEstimadaKm: _parseDecimal(json['distancia_estimada_km']),
      duracionEstimadaMin: (json['duracion_estimada_min'] as num).toInt(),
      fechaVigenciaDesde: json['fecha_vigencia_desde'] as String,
      fechaVigenciaHasta: json['fecha_vigencia_hasta'] as String?,
      vigente: json['vigente'] as bool,
      observacion: json['observacion'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// 9. VEHÍCULO
// *********************************************************
class MiAsignacionVehiculoModel {
  final int idVehiculo;
  final String codigo;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final String color;
  final String tipoVehiculo;
  final double capacidadMaxima;
  final String unidadCapacidad;
  final double kilometraje;
  final String estadoOperativo;
  final String? observacion;
  final String? fotoUrl;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const MiAsignacionVehiculoModel({
    required this.idVehiculo,
    required this.codigo,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.color,
    required this.tipoVehiculo,
    required this.capacidadMaxima,
    required this.unidadCapacidad,
    required this.kilometraje,
    required this.estadoOperativo,
    required this.observacion,
    required this.fotoUrl,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory MiAsignacionVehiculoModel.fromJson(Map<String, dynamic> json) {
    return MiAsignacionVehiculoModel(
      idVehiculo: (json['id_vehiculo'] as num).toInt(),
      codigo: json['codigo'] as String,
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      anio: (json['anio'] as num).toInt(),
      color: json['color'] as String,
      tipoVehiculo: json['tipo_vehiculo'] as String,
      capacidadMaxima: _parseDecimal(json['capacidad_maxima']),
      unidadCapacidad: json['unidad_capacidad'] as String,
      kilometraje: _parseDecimal(json['kilometraje']),
      estadoOperativo: json['estado_operativo'] as String,
      observacion: json['observacion'] as String?,
      fotoUrl: json['foto_url'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// PARSEO DE DECIMALES: STRING O NUMBER
// *********************************************************
double _parseDecimal(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.parse(value);
  }

  throw FormatException('Valor decimal inválido: $value');
}
