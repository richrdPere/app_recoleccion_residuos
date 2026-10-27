import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class DirectionsRepository {
  /// Calcula un camino desde un origen hasta un destino,
  /// pasando por los puntos intermedios en el orden indicado.
  Future<Resource<RutaCalculadaEntity>> calcularRuta({
    required CoordenadaEntity origen,
    required CoordenadaEntity destino,
    List<CoordenadaEntity> puntosIntermedios = const [],
    PerfilDesplazamiento perfil = PerfilDesplazamiento.conduccion,
    bool incluirInstrucciones = false,
  });
}
