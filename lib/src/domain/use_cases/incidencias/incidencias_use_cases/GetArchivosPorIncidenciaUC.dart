import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetArchivosPorIncidenciaUC {
  IncidenciasRepository incidenciaRepository;
  GetArchivosPorIncidenciaUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<List<IncidenciaArchivoListadoModel>>>> run({
    required int idIncidencia,
  }) =>
      incidenciaRepository.getArchivosPorIncidencia(idIncidencia: idIncidencia);
}
