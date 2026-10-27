import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ObtenerDireccionUC {
  GeocodingRepository geocodingRepository;
  ObtenerDireccionUC(this.geocodingRepository);

  Future<Resource<List<DireccionGeograficaEntity>>> run({
    required CoordenadaEntity coordenada,
  }) => geocodingRepository.obtenerDireccion(coordenada: coordenada);
}
