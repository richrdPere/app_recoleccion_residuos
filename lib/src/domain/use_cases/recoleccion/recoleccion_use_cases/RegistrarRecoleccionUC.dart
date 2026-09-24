import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RegistrarRecoleccionUC {
  RecoleccionRepository recoleccionRepository;
  RegistrarRecoleccionUC(this.recoleccionRepository);

  Future<Resource<ApiResponse<RegistrarRecoleccionDataModel>>> run({
    required RegistrarRecoleccionRequest request,
  }) => recoleccionRepository.registrarRecoleccion(request: request);
}
