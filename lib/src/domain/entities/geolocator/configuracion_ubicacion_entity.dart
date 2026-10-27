enum PrecisionUbicacion { baja, media, alta, maxima }

class ConfiguracionUbicacionEntity {
  final PrecisionUbicacion precision;

  /// Distancia mínima solicitada entre actualizaciones.
  final int distanciaMinimaMetros;

  /// Intervalo deseado.
  /// Su aplicación depende de la plataforma.
  final Duration? intervalo;

  const ConfiguracionUbicacionEntity({
    this.precision = PrecisionUbicacion.alta,
    this.distanciaMinimaMetros = 10,
    this.intervalo,
  }) : assert(distanciaMinimaMetros >= 0),
       assert(intervalo == null || intervalo > Duration.zero);
}
