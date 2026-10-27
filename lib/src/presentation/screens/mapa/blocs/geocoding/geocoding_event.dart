import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

abstract class GeocodingEvent {
  const GeocodingEvent();
}

// *********************************************************
// BUSCAR DIRECCIÓN POR TEXTO
// *********************************************************

class BuscarDireccionGeocoding extends GeocodingEvent {
  final String texto;
  final CoordenadaEntity? proximidad;
  final LimitesGeograficosEntity? limites;
  final String codigoPais;
  final int limite;

  const BuscarDireccionGeocoding({
    required this.texto,
    this.proximidad,
    this.limites,
    this.codigoPais = 'pe',
    this.limite = 5,
  });
}

// *********************************************************
// OBTENER DIRECCIÓN POR COORDENADAS
// *********************************************************

class ObtenerDireccionGeocoding extends GeocodingEvent {
  final CoordenadaEntity coordenada;

  const ObtenerDireccionGeocoding({required this.coordenada});
}

// *********************************************************
// LIMPIAR AMBOS RESULTADOS
// *********************************************************

class LimpiarGeocoding extends GeocodingEvent {
  const LimpiarGeocoding();
}
