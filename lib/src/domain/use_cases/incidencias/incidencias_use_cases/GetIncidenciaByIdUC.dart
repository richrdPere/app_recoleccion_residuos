import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetIncidenciaByIdUC {
  IncidenciasRepository incidenciaRepository;
  GetIncidenciaByIdUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<IncidenciaDetalleModel>>> run({
    required int idIncidencia,
  }) => incidenciaRepository.getIncidenciaById(idIncidencia: idIncidencia);
}
