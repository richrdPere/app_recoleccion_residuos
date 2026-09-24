import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetRecoleccionByIdUC {
  RecoleccionRepository recoleccionRepository;
  GetRecoleccionByIdUC(this.recoleccionRepository);

  Future<Resource<ApiResponse<RecoleccionDetalleDataModel>>> run({
    required int idRecoleccion,
  }) => recoleccionRepository.getRecoleccionById(idRecoleccion: idRecoleccion);
}
