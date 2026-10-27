class MapaConfiguracion {
  final double latitud;
  final double longitud;
  final double zoom;
  final double inclinacion;
  final double orientacion;
  final String estiloUri;

  const MapaConfiguracion({
    required this.latitud,
    required this.longitud,
    required this.estiloUri,
    this.zoom = 14,
    this.inclinacion = 0,
    this.orientacion = 0,
  });
}