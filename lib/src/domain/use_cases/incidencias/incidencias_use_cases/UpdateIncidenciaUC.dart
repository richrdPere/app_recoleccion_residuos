import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class UpdateIncidenciaUC {
  IncidenciasRepository incidenciaRepository;
  UpdateIncidenciaUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<UpdateIncidenciaDataModel>>> run({
    required int idIncidencia,
    required UpdateIncidenciaRequest request,
  }) => incidenciaRepository.updateIncidencia(
    idIncidencia: idIncidencia,
    request: request,
  );
}
