// *********************************************************
// 1. RESPUESTAS PERMITIDAS
// *********************************************************
enum RespuestaAsignacion {
  aceptado('ACEPTADO'),
  rechazado('RECHAZADO');

  final String value;

  const RespuestaAsignacion(this.value);
}

// *********************************************************
// 2. REQUEST
// *********************************************************
class ResponderAsignacionRequest {
  final RespuestaAsignacion estadoAsignacion;
  final String? observacion;

  const ResponderAsignacionRequest({
    required this.estadoAsignacion,
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    final normalizedObservation = observacion?.trim();

    return {
      'estado_asignacion': estadoAsignacion.value,
      'observacion':
          normalizedObservation == null || normalizedObservation.isEmpty
          ? null
          : normalizedObservation,
    };
  }
}

// *********************************************************
// 3. DATOS DE RESPUESTA
// *********************************************************
class ResponderAsignacionDataModel {
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

  const ResponderAsignacionDataModel({
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
  });

  factory ResponderAsignacionDataModel.fromJson(Map<String, dynamic> json) {
    return ResponderAsignacionDataModel(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_programacion_personal': idProgramacionPersonal,
      'id_programacion': idProgramacion,
      'id_personal': idPersonal,
      'funcion': funcion,
      'es_principal': esPrincipal,
      'estado_asignacion': estadoAsignacion,
      'fecha_respuesta': fechaRespuesta,
      'observacion': observacion,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}
