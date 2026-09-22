double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();

  return double.parse(value as String);
}

double? _toNullableDouble(dynamic value) {
  return value == null ? null : _toDouble(value);
}

class TrackingPosicionModel {
  final int idPosicion;
  final int idRecorrido;
  final int idUsuario;

  final double latitud;
  final double longitud;
  final double? precisionGps;
  final double? altitud;
  final double? velocidadMps;
  final double? rumbo;
  final double? nivelBateria;

  final bool esUbicacionSimulada;

  final String fechaDispositivo;
  final String fechaRecepcion;
  final String claveIdempotencia;

  final bool esValida;
  final String? motivoInvalidez;
  final String origen;
  final String createdAt;

  TrackingPosicionModel.fromJson(Map<String, dynamic> json)
    : idPosicion = (json['id_posicion'] as num).toInt(),
      idRecorrido = (json['id_recorrido'] as num).toInt(),
      idUsuario = (json['id_usuario'] as num).toInt(),
      latitud = _toDouble(json['latitud']),
      longitud = _toDouble(json['longitud']),
      precisionGps = _toNullableDouble(json['precision_gps']),
      altitud = _toNullableDouble(json['altitud']),
      velocidadMps = _toNullableDouble(json['velocidad_mps']),
      rumbo = _toNullableDouble(json['rumbo']),
      nivelBateria = _toNullableDouble(json['nivel_bateria']),
      esUbicacionSimulada = json['es_ubicacion_simulada'] as bool,
      fechaDispositivo = json['fecha_dispositivo'] as String,
      fechaRecepcion = json['fecha_recepcion'] as String,
      claveIdempotencia = json['clave_idempotencia'] as String,
      esValida = json['es_valida'] as bool,
      motivoInvalidez = json['motivo_invalidez'] as String?,
      origen = json['origen'] as String,
      createdAt = json['created_at'] as String;
}
