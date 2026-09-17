class FinalizarRecorridoRequest {
  final double latitud;
  final double longitud;
  final double? precisionGps;
  final double? kilometraje;
  final String? observacion;
  final String? claveIdempotencia;
  final DateTime? fechaEvento;

  const FinalizarRecorridoRequest({
    required this.latitud,
    required this.longitud,
    this.precisionGps,
    this.kilometraje,
    this.observacion,
    this.claveIdempotencia,
    this.fechaEvento,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      if (precisionGps != null) 'precision_gps': precisionGps,
      if (kilometraje != null) 'kilometraje': kilometraje,
      if (observacion != null) 'observacion': observacion,
      if (claveIdempotencia != null) 'clave_idempotencia': claveIdempotencia,
      if (fechaEvento != null)
        'fecha_evento': fechaEvento!.toUtc().toIso8601String(),
    };
  }
}
