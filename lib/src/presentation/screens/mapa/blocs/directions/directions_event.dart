import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

abstract class DirectionsEvent {
  const DirectionsEvent();
}

// *********************************************************
// CALCULAR RUTA
// *********************************************************

class CalcularRutaDirections extends DirectionsEvent {
  final CoordenadaEntity origen;
  final CoordenadaEntity destino;
  final List<CoordenadaEntity> puntosIntermedios;
  final PerfilDesplazamiento perfil;
  final bool incluirInstrucciones;

  CalcularRutaDirections({
    required this.origen,
    required this.destino,
    List<CoordenadaEntity> puntosIntermedios = const [],
    this.perfil = PerfilDesplazamiento.conduccion,
    this.incluirInstrucciones = false,
  }) : puntosIntermedios = List.unmodifiable(puntosIntermedios);
}

// *********************************************************
// LIMPIAR RUTA
// *********************************************************

class LimpiarRutaDirections extends DirectionsEvent {
  const LimpiarRutaDirections();
}
