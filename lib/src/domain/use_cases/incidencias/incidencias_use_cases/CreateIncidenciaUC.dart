import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class CreateIncidenciaUC {
  IncidenciasRepository incidenciaRepository;
  CreateIncidenciaUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<CreateIncidenciaDataModel>>> run({
    required CreateIncidenciaRequest request,
  }) => incidenciaRepository.createIncidencia(request: request);
}
