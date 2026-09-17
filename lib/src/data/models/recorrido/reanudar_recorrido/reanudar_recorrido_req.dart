class ReanudarRecorridoRequest {
  final double? latitud;
  final double? longitud;
  final double? precisionGps;
  final String? observacion;
  final String? claveIdempotencia;
  final DateTime? fechaEvento;

  const ReanudarRecorridoRequest({
    this.latitud,
    this.longitud,
    this.precisionGps,
    this.observacion,
    this.claveIdempotencia,
    this.fechaEvento,
  });

  Map<String, dynamic> toJson() {
    return {
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (precisionGps != null) 'precision_gps': precisionGps,
      if (observacion != null) 'observacion': observacion,
      if (claveIdempotencia != null) 'clave_idempotencia': claveIdempotencia,
      if (fechaEvento != null)
        'fecha_evento': fechaEvento!.toUtc().toIso8601String(),
    };
  }
}
