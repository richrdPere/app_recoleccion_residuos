import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class BuscarDireccionUC {
  GeocodingRepository geocodingRepository;
  BuscarDireccionUC(this.geocodingRepository);

  Future<Resource<List<DireccionGeograficaEntity>>> run({
    required String texto,
    CoordenadaEntity? proximidad,
    LimitesGeograficosEntity? limites,
    String codigoPais = 'pe',
    int limite = 5,
  }) => geocodingRepository.buscarDireccion(
    texto: texto,
    proximidad: proximidad,
    limites: limites,
    codigoPais: codigoPais,
    limite: limite,
  );
}
