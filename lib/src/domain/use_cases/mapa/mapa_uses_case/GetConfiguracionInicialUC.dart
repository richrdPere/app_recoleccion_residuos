import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

class GetConfiguracionInicialUC {
  MapaRepository mapaRepository;
  GetConfiguracionInicialUC(this.mapaRepository);

  MapaConfiguracion run() => mapaRepository.getConfiguracionInicial();
}
