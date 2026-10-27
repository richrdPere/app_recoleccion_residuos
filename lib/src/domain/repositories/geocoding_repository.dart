import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class GeocodingRepository {
  /// Convierte texto en posibles ubicaciones.
  Future<Resource<List<DireccionGeograficaEntity>>> buscarDireccion({
    required String texto,
    CoordenadaEntity? proximidad,
    LimitesGeograficosEntity? limites,
    String codigoPais = 'pe',
    int limite = 5,
  });

  /// Obtiene posibles direcciones para unas coordenadas.
  Future<Resource<List<DireccionGeograficaEntity>>> obtenerDireccion({
    required CoordenadaEntity coordenada,
  });
}