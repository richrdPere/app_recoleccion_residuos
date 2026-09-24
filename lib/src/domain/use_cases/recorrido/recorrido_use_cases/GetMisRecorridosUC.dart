import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetMisRecorridosUC {
  RecorridoRepository recorridoRepository;
  GetMisRecorridosUC(this.recorridoRepository);

  Future<Resource<ApiResponse<MisRecorridosDataModel>>> run({
    required int page,
    required int limit,
  }) => recorridoRepository.getMisRecorridos(page: page, limit: limit);
}
