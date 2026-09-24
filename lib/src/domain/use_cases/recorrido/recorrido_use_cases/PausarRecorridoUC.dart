import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class PausarRecorridoUC {
  RecorridoRepository recorridoRepository;
  PausarRecorridoUC(this.recorridoRepository);

  Future<Resource<ApiResponse<RecorridoDataModel>>> run({
    required int idRecorrido,
    required PausarRecorridoRequest request,
  }) => recorridoRepository.pausarRecorrido(
    idRecorrido: idRecorrido,
    request: request,
  );
}
