// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsService directionsService;

  DirectionsRepositoryImpl(this.directionsService);

  // *********************************************************
  // 1. CALCULAR RUTA
  // *********************************************************
  @override
  Future<Resource<RutaCalculadaEntity>> calcularRuta({
    required CoordenadaEntity origen,
    required CoordenadaEntity destino,
    List<CoordenadaEntity> puntosIntermedios = const [],
    PerfilDesplazamiento perfil = PerfilDesplazamiento.conduccion,
    bool incluirInstrucciones = false,
  }) async {
    return await directionsService.calcularRuta(
      origen: origen,
      destino: destino,
      puntosIntermedios: puntosIntermedios,
      perfil: perfil,
      incluirInstrucciones: incluirInstrucciones,
    );
  }
}