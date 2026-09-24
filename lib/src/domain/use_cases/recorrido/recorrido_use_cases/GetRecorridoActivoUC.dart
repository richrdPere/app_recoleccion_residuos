import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetRecorridoActivoUC {
  RecorridoRepository recorridoRepository;
  GetRecorridoActivoUC(this.recorridoRepository);

  Future<Resource<ApiResponse<RecorridoDataModel?>>> run() =>
      recorridoRepository.getRecorridoActivo();
}
