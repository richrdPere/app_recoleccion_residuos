import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class CalcularRutaUC {
  DirectionsRepository directionsRepository;
  CalcularRutaUC(this.directionsRepository);

  Future<Resource<RutaCalculadaEntity>> run({
    required CoordenadaEntity origen,
    required CoordenadaEntity destino,
    List<CoordenadaEntity> puntosIntermedios = const [],
    PerfilDesplazamiento perfil = PerfilDesplazamiento.conduccion,
    bool incluirInstrucciones = false,
  }) => directionsRepository.calcularRuta(
    origen: origen,
    destino: destino,
    puntosIntermedios: puntosIntermedios,
    perfil: perfil,
    incluirInstrucciones: incluirInstrucciones,
  );
}
