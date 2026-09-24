import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class FinalizarRecorridoUC {
  RecorridoRepository recorridoRepository;
  FinalizarRecorridoUC(this.recorridoRepository);

  Future<Resource<ApiResponse<RecorridoDataModel>>> run({
    required int idRecorrido,
    required FinalizarRecorridoRequest request,
  }) => recorridoRepository.finalizarRecorrido(
    idRecorrido: idRecorrido,
    request: request,
  );
}
