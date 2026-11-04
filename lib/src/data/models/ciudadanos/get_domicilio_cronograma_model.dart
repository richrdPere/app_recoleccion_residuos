// *********************************************************
// DATA - CRONOGRAMA DEL DOMICILIO
// *********************************************************

class GetDomicilioCronogramaDataModel {
  final String fechaConsulta;
  final String fechaReferencia;

  final DateTime consultadoEn;
  final String zonaHoraria;

  final CronogramaPeriodoModel periodo;
  final CronogramaDomicilioModel domicilio;

  final List<CronogramaHorarioModel> horarios;

  final List<CronogramaEventoModel> eventosHabituales;
  final List<CronogramaEventoModel> serviciosProgramados;
  final List<CronogramaEventoModel> calendario;
  final List<CronogramaEventoModel> serviciosEnCurso;

  final CronogramaEventoModel? proximaRecoleccion;
  final CronogramaEventoModel? proximaReferenciaHabitual;

  final bool tieneProximaRecoleccionProgramada;

  const GetDomicilioCronogramaDataModel({
    required this.fechaConsulta,
    required this.fechaReferencia,
    required this.consultadoEn,
    required this.zonaHoraria,
    required this.periodo,
    required this.domicilio,
    required this.horarios,
    required this.eventosHabituales,
    required this.serviciosProgramados,
    required this.calendario,
    required this.serviciosEnCurso,
    this.proximaRecoleccion,
    this.proximaReferenciaHabitual,
    required this.tieneProximaRecoleccionProgramada,
  });

  factory GetDomicilioCronogramaDataModel.fromJson(Map<String, dynamic> json) {
    return GetDomicilioCronogramaDataModel(
      fechaConsulta: json['fecha_consulta'] as String,
      fechaReferencia: json['fecha_referencia'] as String,

      consultadoEn: DateTime.parse(json['consultado_en'] as String),

      zonaHoraria: json['zona_horaria'] as String,

      periodo: CronogramaPeriodoModel.fromJson(
        Map<String, dynamic>.from(json['periodo'] as Map),
      ),

      domicilio: CronogramaDomicilioModel.fromJson(
        Map<String, dynamic>.from(json['domicilio'] as Map),
      ),

      horarios: (json['horarios'] as List)
          .map(
            (item) => CronogramaHorarioModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),

      eventosHabituales: _cronogramaEventos(json['eventos_habituales']),

      serviciosProgramados: _cronogramaEventos(json['servicios_programados']),

      calendario: _cronogramaEventos(json['calendario']),

      serviciosEnCurso: _cronogramaEventos(json['servicios_en_curso']),

      proximaRecoleccion: json['proxima_recoleccion'] == null
          ? null
          : CronogramaEventoModel.fromJson(
              Map<String, dynamic>.from(json['proxima_recoleccion'] as Map),
            ),

      proximaReferenciaHabitual: json['proxima_referencia_habitual'] == null
          ? null
          : CronogramaEventoModel.fromJson(
              Map<String, dynamic>.from(
                json['proxima_referencia_habitual'] as Map,
              ),
            ),

      tieneProximaRecoleccionProgramada:
          json['tiene_proxima_recoleccion_programada'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha_consulta': fechaConsulta,
      'fecha_referencia': fechaReferencia,
      'consultado_en': consultadoEn.toUtc().toIso8601String(),
      'zona_horaria': zonaHoraria,
      'periodo': periodo.toJson(),
      'domicilio': domicilio.toJson(),

      'horarios': horarios.map((item) => item.toJson()).toList(),

      'eventos_habituales': eventosHabituales
          .map((item) => item.toJson())
          .toList(),

      'servicios_programados': serviciosProgramados
          .map((item) => item.toJson())
          .toList(),

      'calendario': calendario.map((item) => item.toJson()).toList(),

      'servicios_en_curso': serviciosEnCurso
          .map((item) => item.toJson())
          .toList(),

      'proxima_recoleccion': proximaRecoleccion?.toJson(),

      'proxima_referencia_habitual': proximaReferenciaHabitual?.toJson(),

      'tiene_proxima_recoleccion_programada': tieneProximaRecoleccionProgramada,
    };
  }
}

// *********************************************************
// PERIODO CONSULTADO
// Las fechas sin hora se conservan como YYYY-MM-DD.
// *********************************************************

class CronogramaPeriodoModel {
  final String fechaDesde;
  final String fechaHasta;

  const CronogramaPeriodoModel({
    required this.fechaDesde,
    required this.fechaHasta,
  });

  factory CronogramaPeriodoModel.fromJson(Map<String, dynamic> json) {
    return CronogramaPeriodoModel(
      fechaDesde: json['fecha_desde'] as String,
      fechaHasta: json['fecha_hasta'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'fecha_desde': fechaDesde, 'fecha_hasta': fechaHasta};
  }
}

// *********************************************************
// DOMICILIO
// *********************************************************

class CronogramaDomicilioModel {
  final int idDomicilio;
  final String nombreDomicilio;
  final String direccion;
  final String? referencia;
  final double latitud;
  final double longitud;
  final bool esPrincipal;
  final CronogramaZonaModel? zona;
  final CronogramaRutaModel? ruta;

  const CronogramaDomicilioModel({
    required this.idDomicilio,
    required this.nombreDomicilio,
    required this.direccion,
    this.referencia,
    required this.latitud,
    required this.longitud,
    required this.esPrincipal,
    this.zona,
    this.ruta,
  });

  factory CronogramaDomicilioModel.fromJson(Map<String, dynamic> json) {
    return CronogramaDomicilioModel(
      idDomicilio: _cronogramaInt(json['id_domicilio']),
      nombreDomicilio: json['nombre_domicilio'] as String,
      direccion: json['direccion'] as String,
      referencia: json['referencia'] as String?,
      latitud: _cronogramaDouble(json['latitud']),
      longitud: _cronogramaDouble(json['longitud']),
      esPrincipal: json['es_principal'] as bool,
      zona: json['zona'] == null
          ? null
          : CronogramaZonaModel.fromJson(
              Map<String, dynamic>.from(json['zona'] as Map),
            ),
      ruta: json['ruta'] == null
          ? null
          : CronogramaRutaModel.fromJson(
              Map<String, dynamic>.from(json['ruta'] as Map),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_domicilio': idDomicilio,
      'nombre_domicilio': nombreDomicilio,
      'direccion': direccion,
      'referencia': referencia,
      'latitud': latitud,
      'longitud': longitud,
      'es_principal': esPrincipal,
      'zona': zona?.toJson(),
      'ruta': ruta?.toJson(),
    };
  }
}

// *********************************************************
// ZONA
// *********************************************************

class CronogramaZonaModel {
  final int idZona;
  final String nombre;

  const CronogramaZonaModel({required this.idZona, required this.nombre});

  factory CronogramaZonaModel.fromJson(Map<String, dynamic> json) {
    return CronogramaZonaModel(
      idZona: _cronogramaInt(json['id_zona']),
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_zona': idZona, 'nombre': nombre};
  }
}

// *********************************************************
// RUTA
// *********************************************************

class CronogramaRutaModel {
  final int idRuta;
  final String nombre;

  const CronogramaRutaModel({required this.idRuta, required this.nombre});

  factory CronogramaRutaModel.fromJson(Map<String, dynamic> json) {
    return CronogramaRutaModel(
      idRuta: _cronogramaInt(json['id_ruta']),
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_ruta': idRuta, 'nombre': nombre};
  }
}

// *********************************************************
// HORARIO DE RUTA
// *********************************************************

class CronogramaHorarioModel {
  final int idRutaHorario;
  final int idRuta;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final String frecuencia;
  final String fechaVigenciaDesde;
  final String? fechaVigenciaHasta;
  final String? observacion;
  final bool estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CronogramaHorarioModel({
    required this.idRutaHorario,
    required this.idRuta,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.frecuencia,
    required this.fechaVigenciaDesde,
    this.fechaVigenciaHasta,
    this.observacion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CronogramaHorarioModel.fromJson(Map<String, dynamic> json) {
    return CronogramaHorarioModel(
      idRutaHorario: _cronogramaInt(json['id_ruta_horario']),
      idRuta: _cronogramaInt(json['id_ruta']),
      diaSemana: json['dia_semana'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      frecuencia: json['frecuencia'] as String,
      fechaVigenciaDesde: json['fecha_vigencia_desde'] as String,
      fechaVigenciaHasta: json['fecha_vigencia_hasta'] as String?,
      observacion: json['observacion'] as String?,
      estado: json['estado'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ruta_horario': idRutaHorario,
      'id_ruta': idRuta,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'frecuencia': frecuencia,
      'fecha_vigencia_desde': fechaVigenciaDesde,
      'fecha_vigencia_hasta': fechaVigenciaHasta,
      'observacion': observacion,
      'estado': estado,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}

// *********************************************************
// PRÓXIMA RECOLECCIÓN
// *********************************************************

// *********************************************************
// EVENTO DEL CRONOGRAMA
// HORARIO_HABITUAL o SERVICIO_PROGRAMADO
// *********************************************************

class CronogramaEventoModel {
  final String idEvento;
  final String tipo;

  // El backend lo envía en eventos habituales.
  // Puede estar ausente en servicios programados.
  final bool? confirmado;

  final int? idHorario;
  final int? idProgramacion;
  final int? idRecorrido;

  final String fecha;
  final String diaSemana;

  final String? frecuencia;

  final String horaInicio;
  final String horaFin;

  // Se conserva el texto con su offset original (-05:00).
  final String inicio;
  final String fin;

  final String estado;

  // Valor calculado por el backend al consultar.
  final bool franjaVencida;

  const CronogramaEventoModel({
    required this.idEvento,
    required this.tipo,
    this.confirmado,
    this.idHorario,
    this.idProgramacion,
    this.idRecorrido,
    required this.fecha,
    required this.diaSemana,
    this.frecuencia,
    required this.horaInicio,
    required this.horaFin,
    required this.inicio,
    required this.fin,
    required this.estado,
    required this.franjaVencida,
  });

  factory CronogramaEventoModel.fromJson(Map<String, dynamic> json) {
    final inicio = json['inicio'] as String;
    final fin = json['fin'] as String;

    // Validar que sean instantes con zona horaria explícita.
    final offsetPattern = RegExp(r'(?:Z|[+-]\d{2}:\d{2})$');

    if (!offsetPattern.hasMatch(inicio) || !offsetPattern.hasMatch(fin)) {
      throw const FormatException(
        'El evento no contiene una zona horaria válida.',
      );
    }

    final inicioDate = DateTime.parse(inicio);
    final finDate = DateTime.parse(fin);

    if (!finDate.isAfter(inicioDate)) {
      throw const FormatException(
        'La hora final del evento debe ser posterior a la inicial.',
      );
    }

    return CronogramaEventoModel(
      idEvento: json['id_evento'] as String,
      tipo: json['tipo'] as String,

      confirmado: json['confirmado'] as bool?,

      idHorario: _cronogramaNullableInt(json['id_horario']),

      idProgramacion: _cronogramaNullableInt(json['id_programacion']),

      idRecorrido: _cronogramaNullableInt(json['id_recorrido']),

      fecha: json['fecha'] as String,
      diaSemana: json['dia_semana'] as String,
      frecuencia: json['frecuencia'] as String?,

      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,

      inicio: inicio,
      fin: fin,

      estado: json['estado'] as String,
      franjaVencida: json['franja_vencida'] as bool,
    );
  }

  // =========================================================
  // IDENTIFICACIÓN
  // =========================================================

  bool get esHorarioHabitual => tipo == 'HORARIO_HABITUAL';

  bool get esServicioProgramado => tipo == 'SERVICIO_PROGRAMADO';

  // =========================================================
  // ESTADO
  // =========================================================

  bool get esReferencial => estado == 'REFERENCIAL';

  bool get estaPendiente => estado == 'PENDIENTE';

  bool get estaEnCurso => estado == 'EN_CURSO';

  bool get estaPausado => estado == 'PAUSADO';

  bool get estaFinalizado => estado == 'FINALIZADO';

  bool get estaCancelado => estado == 'CANCELADO';

  String get estadoLabel {
    switch (estado) {
      case 'REFERENCIAL':
        return 'Horario de referencia';
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_CURSO':
        return 'En curso';
      case 'PAUSADO':
        return 'Pausado';
      case 'FINALIZADO':
        return 'Finalizado';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  // Instantes para comparar fechas.
  // DateTime.parse interpreta el offset del servidor.
  DateTime get inicioDateTime => DateTime.parse(inicio);

  DateTime get finDateTime => DateTime.parse(fin);

  Map<String, dynamic> toJson() {
    return {
      'id_evento': idEvento,
      'tipo': tipo,

      if (confirmado != null) 'confirmado': confirmado,

      'id_horario': idHorario,
      'id_programacion': idProgramacion,

      if (esServicioProgramado || idRecorrido != null)
        'id_recorrido': idRecorrido,

      'fecha': fecha,
      'dia_semana': diaSemana,
      'frecuencia': frecuencia,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'inicio': inicio,
      'fin': fin,
      'estado': estado,
      'franja_vencida': franjaVencida,
    };
  }
}

// Alias para referencias al nombre anterior en tu proyecto.
// No restablece los campos que ahora son nullable.
typedef CronogramaProximaRecoleccionModel = CronogramaEventoModel;

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************
int? _cronogramaNullableInt(dynamic value) {
  return value == null ? null : _cronogramaInt(value);
}

List<CronogramaEventoModel> _cronogramaEventos(dynamic value) {
  if (value is! List) {
    throw const FormatException(
      'El servidor no devolvió una lista válida de eventos.',
    );
  }

  return value
      .map(
        (item) => CronogramaEventoModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

int _cronogramaInt(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException(
    'El servidor devolvió un identificador inválido.',
  );
}

double _cronogramaDouble(dynamic value) {
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
      'El servidor devolvió una coordenada inválida.',
    );
  }

  return parsed;
}
