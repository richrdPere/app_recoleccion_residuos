class RegistrarRecoleccionRequest {
  final int idRecorrido;
  final int idRutaPunto;
  final DateTime fechaDispositivo;
  final double latitud;
  final double longitud;
  final double? precisionGps;
  final double? cantidadRecolectada;
  final String unidadMedida;
  final String? observacion;
  final String claveIdempotencia;

  const RegistrarRecoleccionRequest({
    required this.idRecorrido,
    required this.idRutaPunto,
    required this.fechaDispositivo,
    required this.latitud,
    required this.longitud,
    this.precisionGps,
    this.cantidadRecolectada,
    required this.unidadMedida,
    this.observacion,
    required this.claveIdempotencia,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_recorrido': idRecorrido,
      'id_ruta_punto': idRutaPunto,
      'fecha_dispositivo': fechaDispositivo.toUtc().toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      if (precisionGps != null) 'precision_gps': precisionGps,
      if (cantidadRecolectada != null)
        'cantidad_recolectada': cantidadRecolectada,
      'unidad_medida': unidadMedida,
      if (observacion != null) 'observacion': observacion,
      'clave_idempotencia': claveIdempotencia,
    };
  }
}

// *********************************************************
// CONVERSIÓN DE DECIMALES
// *********************************************************
double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();

  return double.parse(value as String);
}

double? _toNullableDouble(dynamic value) {
  return value == null ? null : _toDouble(value);
}

// *********************************************************
// DATA DE REGISTRO
// *********************************************************
class RegistrarRecoleccionDataModel {
  final RecoleccionDataModel recoleccion;
  final RecoleccionPuntoRutaModel? punto;
  final bool duplicada;

  RegistrarRecoleccionDataModel.fromJson(Map<String, dynamic> json)
    : recoleccion = RecoleccionDataModel.fromJson(
        Map<String, dynamic>.from(json['recoleccion'] as Map),
      ),
      punto = json['punto'] == null
          ? null
          : RecoleccionPuntoRutaModel.fromJson(
              Map<String, dynamic>.from(json['punto'] as Map),
            ),
      duplicada = json['duplicada'] as bool;
}

// *********************************************************
// RECOLECCIÓN REGISTRADA
// *********************************************************
class RecoleccionDataModel {
  final int idRecoleccion;
  final int idRecorrido;
  final int idRutaPunto;
  final int idUsuario;

  final String fechaDispositivo;
  final String fechaRecepcion;

  final double latitud;
  final double longitud;
  final double? precisionGps;

  final double? distanciaPuntoMetros;
  final bool? dentroRadioPermitido;

  final double? cantidadRecolectada;
  final String? unidadMedida;
  final String? observacion;

  final String claveIdempotencia;
  final String origen;
  final String estadoRecoleccion;

  final String createdAt;
  final String updatedAt;

  RecoleccionDataModel.fromJson(Map<String, dynamic> json)
    : idRecoleccion = (json['id_recoleccion'] as num).toInt(),
      idRecorrido = (json['id_recorrido'] as num).toInt(),
      idRutaPunto = (json['id_ruta_punto'] as num).toInt(),
      idUsuario = (json['id_usuario'] as num).toInt(),
      fechaDispositivo = json['fecha_dispositivo'] as String,
      fechaRecepcion = json['fecha_recepcion'] as String,
      latitud = _toDouble(json['latitud']),
      longitud = _toDouble(json['longitud']),
      precisionGps = _toNullableDouble(json['precision_gps']),
      distanciaPuntoMetros = _toNullableDouble(json['distancia_punto_metros']),
      dentroRadioPermitido = json['dentro_radio_permitido'] as bool?,
      cantidadRecolectada = _toNullableDouble(json['cantidad_recolectada']),
      unidadMedida = json['unidad_medida'] as String?,
      observacion = json['observacion'] as String?,
      claveIdempotencia = json['clave_idempotencia'] as String,
      origen = json['origen'] as String,
      estadoRecoleccion = json['estado_recoleccion'] as String,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String;
}

// *********************************************************
// PUNTO DE RUTA ASOCIADO
// *********************************************************
class RecoleccionPuntoRutaModel {
  final int idRutaPunto;
  final int idRutaVersion;

  final String? codigo;
  final String nombre;
  final String? descripcion;
  final String tipoPunto;

  final double latitud;
  final double longitud;
  final int orden;

  final double? radioAtencionMetros;
  final int? tiempoEstimadoMin;

  final bool obligatorio;
  final bool estado;

  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  RecoleccionPuntoRutaModel.fromJson(Map<String, dynamic> json)
    : idRutaPunto = (json['id_ruta_punto'] as num).toInt(),
      idRutaVersion = (json['id_ruta_version'] as num).toInt(),
      codigo = json['codigo'] as String?,
      nombre = json['nombre'] as String,
      descripcion = json['descripcion'] as String?,
      tipoPunto = json['tipo_punto'] as String,
      latitud = _toDouble(json['latitud']),
      longitud = _toDouble(json['longitud']),
      orden = (json['orden'] as num).toInt(),
      radioAtencionMetros = _toNullableDouble(json['radio_atencion_metros']),
      tiempoEstimadoMin = (json['tiempo_estimado_min'] as num?)?.toInt(),
      obligatorio = json['obligatorio'] as bool,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?;
}
