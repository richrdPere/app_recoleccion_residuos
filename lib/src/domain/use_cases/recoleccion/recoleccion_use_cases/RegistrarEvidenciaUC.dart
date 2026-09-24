import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RegistrarEvidenciaUC {
  RecoleccionRepository recoleccionRepository;
  RegistrarEvidenciaUC(this.recoleccionRepository);

  Future<Resource<ApiResponse<RecoleccionEvidenciaDataModel>>> run({
    required int idRecoleccion,
    required RegistrarEvidenciaRequest request,
  }) => recoleccionRepository.registrarEvidencia(
    request: request,
    idRecoleccion: idRecoleccion,
  );
}
