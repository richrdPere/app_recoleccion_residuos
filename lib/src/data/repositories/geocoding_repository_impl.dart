// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  final GeocodingService geocodingService;

  GeocodingRepositoryImpl(this.geocodingService);

  // *********************************************************
  // 1. BUSCAR DIRECCIÓN
  // *********************************************************
  @override
  Future<Resource<List<DireccionGeograficaEntity>>> buscarDireccion({
    required String texto,
    CoordenadaEntity? proximidad,
    LimitesGeograficosEntity? limites,
    String codigoPais = 'pe',
    int limite = 5,
  }) async {
    final textoBusqueda = texto.trim();

    if (textoBusqueda.isEmpty) {
      return ErrorData(
        message: 'Ingresa una dirección para realizar la búsqueda.',
      );
    }

    if (limite <= 0) {
      return ErrorData(
        message: 'El límite de resultados debe ser mayor que cero.',
      );
    }

    return await geocodingService.buscarDireccion(
      texto: textoBusqueda,
      proximidad: proximidad,
      limites: limites,
      codigoPais: codigoPais.trim().toLowerCase(),
      limite: limite,
    );
  }

  // *********************************************************
  // 2. OBTENER DIRECCIÓN POR COORDENADAS
  // *********************************************************
  @override
  Future<Resource<List<DireccionGeograficaEntity>>> obtenerDireccion({
    required CoordenadaEntity coordenada,
  }) async {
    return await geocodingService.obtenerDireccion(coordenada: coordenada);
  }
}
