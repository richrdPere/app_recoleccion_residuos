class RegistrarRecoleccionLoteRequest {
  final int idRecorrido;
  final List<RecoleccionLoteItemRequest> recolecciones;

  const RegistrarRecoleccionLoteRequest({
    required this.idRecorrido,
    required this.recolecciones,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_recorrido': idRecorrido,
      'recolecciones': recolecciones.map((item) => item.toJson()).toList(),
    };
  }
}

class RecoleccionLoteItemRequest {
  final int idRutaPunto;
  final DateTime fechaDispositivo;
  final double latitud;
  final double longitud;
  final double? precisionGps;
  final double? cantidadRecolectada;
  final String unidadMedida;
  final String? observacion;
  final String claveIdempotencia;

  const RecoleccionLoteItemRequest({
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
