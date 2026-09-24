import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ReanudarRecorridoUC {
  RecorridoRepository recorridoRepository;
  ReanudarRecorridoUC(this.recorridoRepository);

  Future<Resource<ApiResponse<RecorridoDataModel>>> run({
    required int idRecorrido,
    required ReanudarRecorridoRequest request,
  }) => recorridoRepository.reanudarRecorrido(
    idRecorrido: idRecorrido,
    request: request,
  );
}
