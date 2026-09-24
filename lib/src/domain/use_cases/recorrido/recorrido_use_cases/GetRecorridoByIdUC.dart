import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetRecorridoByIdUC {
  RecorridoRepository recorridoRepository;
  GetRecorridoByIdUC(this.recorridoRepository);

  Future<Resource<ApiResponse<RecorridoDataModel?>>> run({
    required int idRecorrido,
  }) => recorridoRepository.getRecorridoById(idRecorrido: idRecorrido);
}
