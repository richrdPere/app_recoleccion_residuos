import '../geografia/coordenada_entity.dart';

class UbicacionEntity {
  final CoordenadaEntity coordenada;

  /// Momento de captura de la posición.
  /// Normalizar a UTC en la implementación.
  final DateTime fechaCaptura;

  /// Precisión horizontal reportada.
  final double? precisionMetros;

  final double? altitudMetros;
  final double? precisionAltitudMetros;

  final double? velocidadMetrosPorSegundo;
  final double? precisionVelocidadMetrosPorSegundo;

  /// Rumbo en grados, normalizado al rango [0, 360).
  final double? rumboGrados;

  final bool? esSimulada;

  const UbicacionEntity({
    required this.coordenada,
    required this.fechaCaptura,
    this.precisionMetros,
    this.altitudMetros,
    this.precisionAltitudMetros,
    this.velocidadMetrosPorSegundo,
    this.precisionVelocidadMetrosPorSegundo,
    this.rumboGrados,
    this.esSimulada,
  });

  double? get velocidadKilometrosPorHora {
    final velocidad = velocidadMetrosPorSegundo;
    return velocidad == null ? null : velocidad * 3.6;
  }

  Duration antiguedadEn(DateTime instante) {
    return instante.toUtc().difference(fechaCaptura.toUtc());
  }
}
