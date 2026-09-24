import 'mis_asignaciones_response.dart';

// *********************************************************
// 1. DETALLE DE PROGRAMACIÓN
// *********************************************************
class ProgramacionDetalleDataModel {
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

  final ProgramacionRutaDetalleModel ruta;
  final ProgramacionVersionDetalleModel versionRuta;
  final MiAsignacionVehiculoModel vehiculo;
  final ProgramacionCreadorModel creador;
  final List<ProgramacionPersonalAsignadoModel> personalAsignado;
  final List<ProgramacionHistorialModel> historial;

  const ProgramacionDetalleDataModel({
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
    required this.creador,
    required this.personalAsignado,
    required this.historial,
  });

  factory ProgramacionDetalleDataModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionDetalleDataModel(
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
      ruta: ProgramacionRutaDetalleModel.fromJson(_asMap(json['ruta'])),
      versionRuta: ProgramacionVersionDetalleModel.fromJson(
        _asMap(json['version_ruta']),
      ),
      vehiculo: MiAsignacionVehiculoModel.fromJson(_asMap(json['vehiculo'])),
      creador: ProgramacionCreadorModel.fromJson(_asMap(json['creador'])),
      personalAsignado: (json['personal_asignado'] as List)
          .map(
            (item) => ProgramacionPersonalAsignadoModel.fromJson(_asMap(item)),
          )
          .toList(),
      historial: (json['historial'] as List)
          .map((item) => ProgramacionHistorialModel.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

// *********************************************************
// 2. RUTA CON ZONA
// Reutiliza los campos de MiAsignacionRutaModel.
// *********************************************************
class ProgramacionRutaDetalleModel extends MiAsignacionRutaModel {
  final ProgramacionZonaModel zona;

  ProgramacionRutaDetalleModel({
    required MiAsignacionRutaModel base,
    required this.zona,
  }) : super(
         idRuta: base.idRuta,
         idZona: base.idZona,
         codigo: base.codigo,
         nombre: base.nombre,
         descripcion: base.descripcion,
         color: base.color,
         estadoRuta: base.estadoRuta,
         estado: base.estado,
         createdAt: base.createdAt,
         updatedAt: base.updatedAt,
         deletedAt: base.deletedAt,
       );

  factory ProgramacionRutaDetalleModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionRutaDetalleModel(
      base: MiAsignacionRutaModel.fromJson(json),
      zona: ProgramacionZonaModel.fromJson(_asMap(json['zona'])),
    );
  }
}

// *********************************************************
// 3. ZONA
// *********************************************************
class ProgramacionZonaModel {
  final int idZona;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String color;
  final ProgramacionPolygonModel poligonoGeojson;
  final double centroLatitud;
  final double centroLongitud;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const ProgramacionZonaModel({
    required this.idZona,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.color,
    required this.poligonoGeojson,
    required this.centroLatitud,
    required this.centroLongitud,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory ProgramacionZonaModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionZonaModel(
      idZona: (json['id_zona'] as num).toInt(),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String,
      poligonoGeojson: ProgramacionPolygonModel.fromJson(
        _asMap(json['poligono_geojson']),
      ),
      centroLatitud: _asDouble(json['centro_latitud']),
      centroLongitud: _asDouble(json['centro_longitud']),
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// 4. POLÍGONO GEOJSON
// *********************************************************
class ProgramacionPolygonModel {
  final String type;

  // Anillos → posiciones → [longitud, latitud].
  final List<List<List<double>>> coordinates;

  const ProgramacionPolygonModel({
    required this.type,
    required this.coordinates,
  });

  factory ProgramacionPolygonModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionPolygonModel(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List)
          .map(
            (ring) => (ring as List)
                .map(
                  (position) => (position as List)
                      .map((value) => (value as num).toDouble())
                      .toList(),
                )
                .toList(),
          )
          .toList(),
    );
  }
}

// *********************************************************
// 5. VERSIÓN DE RUTA CON PUNTOS
// *********************************************************
class ProgramacionVersionDetalleModel extends MiAsignacionRutaVersionModel {
  final List<ProgramacionRutaPuntoModel> puntos;

  ProgramacionVersionDetalleModel({
    required MiAsignacionRutaVersionModel base,
    required this.puntos,
  }) : super(
         idRutaVersion: base.idRutaVersion,
         idRuta: base.idRuta,
         numeroVersion: base.numeroVersion,
         geometriaGeojson: base.geometriaGeojson,
         distanciaEstimadaKm: base.distanciaEstimadaKm,
         duracionEstimadaMin: base.duracionEstimadaMin,
         fechaVigenciaDesde: base.fechaVigenciaDesde,
         fechaVigenciaHasta: base.fechaVigenciaHasta,
         vigente: base.vigente,
         observacion: base.observacion,
         estado: base.estado,
         createdAt: base.createdAt,
         updatedAt: base.updatedAt,
         deletedAt: base.deletedAt,
       );

  factory ProgramacionVersionDetalleModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionVersionDetalleModel(
      base: MiAsignacionRutaVersionModel.fromJson(json),
      puntos: (json['puntos'] as List)
          .map((item) => ProgramacionRutaPuntoModel.fromJson(_asMap(item)))
          .toList(),
    );
  }

  // Devuelve una copia ordenada sin modificar la respuesta.
  List<ProgramacionRutaPuntoModel> get puntosOrdenados {
    return [...puntos]..sort((a, b) => a.orden.compareTo(b.orden));
  }
}

// *********************************************************
// 6. PUNTO DE RUTA
// *********************************************************
class ProgramacionRutaPuntoModel {
  final int idRutaPunto;
  final int idRutaVersion;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String tipoPunto;
  final double latitud;
  final double longitud;
  final int orden;
  final double radioAtencionMetros;
  final int tiempoEstimadoMin;
  final bool obligatorio;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const ProgramacionRutaPuntoModel({
    required this.idRutaPunto,
    required this.idRutaVersion,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.tipoPunto,
    required this.latitud,
    required this.longitud,
    required this.orden,
    required this.radioAtencionMetros,
    required this.tiempoEstimadoMin,
    required this.obligatorio,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory ProgramacionRutaPuntoModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionRutaPuntoModel(
      idRutaPunto: (json['id_ruta_punto'] as num).toInt(),
      idRutaVersion: (json['id_ruta_version'] as num).toInt(),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      tipoPunto: json['tipo_punto'] as String,
      latitud: _asDouble(json['latitud']),
      longitud: _asDouble(json['longitud']),
      orden: (json['orden'] as num).toInt(),
      radioAtencionMetros: _asDouble(json['radio_atencion_metros']),
      tiempoEstimadoMin: (json['tiempo_estimado_min'] as num).toInt(),
      obligatorio: json['obligatorio'] as bool,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// 7. CREADOR
// *********************************************************
class ProgramacionCreadorModel {
  final int idUsuario;
  final String username;
  final String emailAcceso;
  final ProgramacionCreadorPersonaModel persona;

  const ProgramacionCreadorModel({
    required this.idUsuario,
    required this.username,
    required this.emailAcceso,
    required this.persona,
  });

  factory ProgramacionCreadorModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionCreadorModel(
      idUsuario: (json['id_usuario'] as num).toInt(),
      username: json['username'] as String,
      emailAcceso: json['email_acceso'] as String,
      persona: ProgramacionCreadorPersonaModel.fromJson(
        _asMap(json['persona']),
      ),
    );
  }
}

class ProgramacionCreadorPersonaModel {
  final int idPersona;
  final String nombres;
  final String apellidos;

  const ProgramacionCreadorPersonaModel({
    required this.idPersona,
    required this.nombres,
    required this.apellidos,
  });

  factory ProgramacionCreadorPersonaModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionCreadorPersonaModel(
      idPersona: (json['id_persona'] as num).toInt(),
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
    );
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();
}

// *********************************************************
// 8. ASIGNACIÓN DE PERSONAL
// *********************************************************
class ProgramacionPersonalAsignadoModel {
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
  final ProgramacionPersonalModel personal;

  const ProgramacionPersonalAsignadoModel({
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
    required this.personal,
  });

  factory ProgramacionPersonalAsignadoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProgramacionPersonalAsignadoModel(
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
      personal: ProgramacionPersonalModel.fromJson(_asMap(json['personal'])),
    );
  }
}

// *********************************************************
// 9. PERSONAL OPERATIVO
// *********************************************************
class ProgramacionPersonalModel {
  final int idPersonal;
  final int idUsuario;
  final String codigoEmpleado;
  final String fechaIngreso;
  final String? fechaSalida;
  final String tipoContrato;
  final String turnoPreferente;
  final String estadoLaboral;
  final String? observacion;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final ProgramacionPersonalUsuarioModel usuario;
  final ProgramacionConductorModel? conductor;

  const ProgramacionPersonalModel({
    required this.idPersonal,
    required this.idUsuario,
    required this.codigoEmpleado,
    required this.fechaIngreso,
    required this.fechaSalida,
    required this.tipoContrato,
    required this.turnoPreferente,
    required this.estadoLaboral,
    required this.observacion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.usuario,
    required this.conductor,
  });

  factory ProgramacionPersonalModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionPersonalModel(
      idPersonal: (json['id_personal'] as num).toInt(),
      idUsuario: (json['id_usuario'] as num).toInt(),
      codigoEmpleado: json['codigo_empleado'] as String,
      fechaIngreso: json['fecha_ingreso'] as String,
      fechaSalida: json['fecha_salida'] as String?,
      tipoContrato: json['tipo_contrato'] as String,
      turnoPreferente: json['turno_preferente'] as String,
      estadoLaboral: json['estado_laboral'] as String,
      observacion: json['observacion'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
      usuario: ProgramacionPersonalUsuarioModel.fromJson(
        _asMap(json['usuario']),
      ),
      conductor: json['conductor'] == null
          ? null
          : ProgramacionConductorModel.fromJson(_asMap(json['conductor'])),
    );
  }
}

// *********************************************************
// 10. USUARIO Y PERSONA DEL PERSONAL
// *********************************************************
class ProgramacionPersonalUsuarioModel {
  final int idUsuario;
  final String username;
  final String emailAcceso;
  final ProgramacionPersonalPersonaModel persona;

  const ProgramacionPersonalUsuarioModel({
    required this.idUsuario,
    required this.username,
    required this.emailAcceso,
    required this.persona,
  });

  factory ProgramacionPersonalUsuarioModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionPersonalUsuarioModel(
      idUsuario: (json['id_usuario'] as num).toInt(),
      username: json['username'] as String,
      emailAcceso: json['email_acceso'] as String,
      persona: ProgramacionPersonalPersonaModel.fromJson(
        _asMap(json['persona']),
      ),
    );
  }
}

class ProgramacionPersonalPersonaModel {
  final String nombres;
  final String apellidos;
  final String numeroDocumento;
  final String? celular;

  const ProgramacionPersonalPersonaModel({
    required this.nombres,
    required this.apellidos,
    required this.numeroDocumento,
    required this.celular,
  });

  factory ProgramacionPersonalPersonaModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionPersonalPersonaModel(
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      numeroDocumento: json['numero_documento'] as String,
      celular: json['celular'] as String?,
    );
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();
}

// *********************************************************
// 11. PERFIL DEL CONDUCTOR
// *********************************************************
class ProgramacionConductorModel {
  final int idConductor;
  final int idPersonal;
  final String numeroLicencia;
  final String categoriaLicencia;
  final String fechaEmisionLicencia;
  final String fechaVencimientoLicencia;
  final String estadoLicencia;
  final String? restricciones;
  final String? observacion;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const ProgramacionConductorModel({
    required this.idConductor,
    required this.idPersonal,
    required this.numeroLicencia,
    required this.categoriaLicencia,
    required this.fechaEmisionLicencia,
    required this.fechaVencimientoLicencia,
    required this.estadoLicencia,
    required this.restricciones,
    required this.observacion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory ProgramacionConductorModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionConductorModel(
      idConductor: (json['id_conductor'] as num).toInt(),
      idPersonal: (json['id_personal'] as num).toInt(),
      numeroLicencia: json['numero_licencia'] as String,
      categoriaLicencia: json['categoria_licencia'] as String,
      fechaEmisionLicencia: json['fecha_emision_licencia'] as String,
      fechaVencimientoLicencia: json['fecha_vencimiento_licencia'] as String,
      estadoLicencia: json['estado_licencia'] as String,
      restricciones: json['restricciones'] as String?,
      observacion: json['observacion'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// 12. HISTORIAL
// *********************************************************
class ProgramacionHistorialModel {
  final int idHistorial;
  final int idProgramacion;
  final int idUsuario;
  final String tipoEvento;
  final String? estadoAnterior;
  final String? estadoNuevo;

  // Su estructura cambia según el tipo de evento.
  final Map<String, dynamic>? datosAnteriores;
  final Map<String, dynamic>? datosNuevos;

  final String? observacion;
  final String origen;
  final String? ip;
  final String? userAgent;
  final String createdAt;
  final ProgramacionHistorialActorModel actor;

  const ProgramacionHistorialModel({
    required this.idHistorial,
    required this.idProgramacion,
    required this.idUsuario,
    required this.tipoEvento,
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.datosAnteriores,
    required this.datosNuevos,
    required this.observacion,
    required this.origen,
    required this.ip,
    required this.userAgent,
    required this.createdAt,
    required this.actor,
  });

  factory ProgramacionHistorialModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionHistorialModel(
      idHistorial: (json['id_historial'] as num).toInt(),
      idProgramacion: (json['id_programacion'] as num).toInt(),
      idUsuario: (json['id_usuario'] as num).toInt(),
      tipoEvento: json['tipo_evento'] as String,
      estadoAnterior: json['estado_anterior'] as String?,
      estadoNuevo: json['estado_nuevo'] as String?,
      datosAnteriores: json['datos_anteriores'] == null
          ? null
          : _asMap(json['datos_anteriores']),
      datosNuevos: json['datos_nuevos'] == null
          ? null
          : _asMap(json['datos_nuevos']),
      observacion: json['observacion'] as String?,
      origen: json['origen'] as String,
      ip: json['ip'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: json['created_at'] as String,
      actor: ProgramacionHistorialActorModel.fromJson(_asMap(json['actor'])),
    );
  }
}

class ProgramacionHistorialActorModel {
  final int idUsuario;
  final String username;

  const ProgramacionHistorialActorModel({
    required this.idUsuario,
    required this.username,
  });

  factory ProgramacionHistorialActorModel.fromJson(Map<String, dynamic> json) {
    return ProgramacionHistorialActorModel(
      idUsuario: (json['id_usuario'] as num).toInt(),
      username: json['username'] as String,
    );
  }
}

// *********************************************************
// HELPERS PRIVADOS
// *********************************************************
Map<String, dynamic> _asMap(Object? value) {
  return Map<String, dynamic>.from(value as Map);
}

double _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.parse(value);
  }

  throw FormatException('Valor decimal inválido: $value');
}
