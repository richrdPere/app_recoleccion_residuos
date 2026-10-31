import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ChangeIncidenciaEstadoUC {
  IncidenciasRepository incidenciaRepository;
  ChangeIncidenciaEstadoUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<ChangeIncidenciaEstadoDataModel>>> run({
    required int idIncidencia,
    required ChangeIncidenciaEstadoRequest request,
  }) => incidenciaRepository.changeIncidenciaEstado(
    idIncidencia: idIncidencia,
    request: request,
  );
}
