// *********************************************************
// DATA - CRONOGRAMA DEL DOMICILIO
// *********************************************************

class GetDomicilioCronogramaDataModel {
  final String fechaConsulta;
  final CronogramaDomicilioModel domicilio;
  final List<CronogramaHorarioModel> horarios;
  final CronogramaProximaRecoleccionModel? proximaRecoleccion;

  const GetDomicilioCronogramaDataModel({
    required this.fechaConsulta,
    required this.domicilio,
    required this.horarios,
    this.proximaRecoleccion,
  });

  factory GetDomicilioCronogramaDataModel.fromJson(Map<String, dynamic> json) {
    return GetDomicilioCronogramaDataModel(
      fechaConsulta: json['fecha_consulta'] as String,
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
      proximaRecoleccion: json['proxima_recoleccion'] == null
          ? null
          : CronogramaProximaRecoleccionModel.fromJson(
              Map<String, dynamic>.from(json['proxima_recoleccion'] as Map),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha_consulta': fechaConsulta,
      'domicilio': domicilio.toJson(),
      'horarios': horarios.map((item) => item.toJson()).toList(),
      'proxima_recoleccion': proximaRecoleccion?.toJson(),
    };
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

class CronogramaProximaRecoleccionModel {
  final String fecha;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final String frecuencia;
  final int idHorario;

  const CronogramaProximaRecoleccionModel({
    required this.fecha,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.frecuencia,
    required this.idHorario,
  });

  factory CronogramaProximaRecoleccionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CronogramaProximaRecoleccionModel(
      fecha: json['fecha'] as String,
      diaSemana: json['dia_semana'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      frecuencia: json['frecuencia'] as String,
      idHorario: _cronogramaInt(json['id_horario']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'frecuencia': frecuencia,
      'id_horario': idHorario,
    };
  }
}

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************

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
