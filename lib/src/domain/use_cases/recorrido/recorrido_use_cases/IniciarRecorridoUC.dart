import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class IniciarRecorridoUC {
  RecorridoRepository recorridoRepository;
  IniciarRecorridoUC(this.recorridoRepository);

  Future<Resource<ApiResponse<RecorridoDataModel>>> run({
    required int idProgramacion,
    required IniciarRecorridoRequest request,
  }) => recorridoRepository.iniciarRecorrido(
    idProgramacion: idProgramacion,
    request: request,
  );
}
