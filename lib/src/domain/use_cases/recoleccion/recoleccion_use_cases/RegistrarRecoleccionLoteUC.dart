import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RegistrarRecoleccionLoteUC {
  RecoleccionRepository recoleccionRepository;
  RegistrarRecoleccionLoteUC(this.recoleccionRepository);

  Future<Resource<ApiResponse<RegistrarRecoleccionLoteDataModel>>> run({
    required RegistrarRecoleccionLoteRequest request,
  }) => recoleccionRepository.registrarRecoleccionLote(request: request);
}
