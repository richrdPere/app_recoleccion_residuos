import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetRecorridoProgresoUC {
  RecoleccionRepository recoleccionRepository;
  GetRecorridoProgresoUC(this.recoleccionRepository);

  Future<Resource<ApiResponse<RecorridoProgresoDataModel>>> run({
    required int idRecorrido,
  }) => recoleccionRepository.getRecorridoProgreso(idRecorrido: idRecorrido);
}
