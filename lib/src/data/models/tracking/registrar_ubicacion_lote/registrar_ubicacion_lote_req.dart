class RegistrarUbicacionLoteRequest {
  final int idRecorrido;
  final List<UbicacionLoteItemRequest> ubicaciones;

  const RegistrarUbicacionLoteRequest({
    required this.idRecorrido,
    required this.ubicaciones,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_recorrido': idRecorrido,
      'ubicaciones': ubicaciones
          .map((ubicacion) => ubicacion.toJson())
          .toList(),
    };
  }
}

class UbicacionLoteItemRequest {
  final String claveIdempotencia;
  final double latitud;
  final double longitud;

  final double? precisionGps;
  final double? altitud;
  final double? velocidadMps;
  final double? rumbo;
  final double? nivelBateria;

  final bool esUbicacionSimulada;
  final DateTime fechaDispositivo;

  const UbicacionLoteItemRequest({
    required this.claveIdempotencia,
    required this.latitud,
    required this.longitud,
    this.precisionGps,
    this.altitud,
    this.velocidadMps,
    this.rumbo,
    this.nivelBateria,
    required this.esUbicacionSimulada,
    required this.fechaDispositivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'clave_idempotencia': claveIdempotencia,
      'latitud': latitud,
      'longitud': longitud,
      if (precisionGps != null) 'precision_gps': precisionGps,
      if (altitud != null) 'altitud': altitud,
      if (velocidadMps != null) 'velocidad_mps': velocidadMps,
      if (rumbo != null) 'rumbo': rumbo,
      if (nivelBateria != null) 'nivel_bateria': nivelBateria,
      'es_ubicacion_simulada': esUbicacionSimulada,
      'fecha_dispositivo': fechaDispositivo.toUtc().toIso8601String(),
    };
  }
}
