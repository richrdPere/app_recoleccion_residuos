import '../geografia/coordenada_entity.dart';

// ==========================================================
// PERFIL DE DESPLAZAMIENTO
// ==========================================================

enum PerfilDesplazamiento { conduccion, caminata, bicicleta }

// ==========================================================
// RUTA CALCULADA
// ==========================================================

class RutaCalculadaEntity {
  /// Coordenadas ordenadas del camino.
  final List<CoordenadaEntity> geometria;

  final double distanciaMetros;
  final double duracionSegundos;

  /// Cada tramo conecta dos puntos solicitados consecutivos.
  final List<TramoRutaEntity> tramos;

  RutaCalculadaEntity({
    required List<CoordenadaEntity> geometria,
    required this.distanciaMetros,
    required this.duracionSegundos,
    List<TramoRutaEntity> tramos = const [],
  }) : geometria = List.unmodifiable(geometria),
       tramos = List.unmodifiable(tramos);
}

// ==========================================================
// TRAMO
// ==========================================================

class TramoRutaEntity {
  final double distanciaMetros;
  final double duracionSegundos;
  final String? resumen;
  final List<PasoRutaEntity> pasos;

  TramoRutaEntity({
    required this.distanciaMetros,
    required this.duracionSegundos,
    this.resumen,
    List<PasoRutaEntity> pasos = const [],
  }) : pasos = List.unmodifiable(pasos);
}

// ==========================================================
// PASO / INSTRUCCIÓN
// ==========================================================

class PasoRutaEntity {
  /// Ejemplo: "Gira a la derecha".
  final String instruccion;

  final String? nombreVia;
  final CoordenadaEntity ubicacionManiobra;
  final double distanciaMetros;
  final double duracionSegundos;

  const PasoRutaEntity({
    required this.instruccion,
    required this.ubicacionManiobra,
    required this.distanciaMetros,
    required this.duracionSegundos,
    this.nombreVia,
  });
}
