import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class AgregarArchivosUC {
  IncidenciasRepository incidenciaRepository;
  AgregarArchivosUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<List<IncidenciaArchivoCreadoModel>>>> run({
    required int idIncidencia,
    required AgregarIncidenciaArchivosRequest request,
  }) => incidenciaRepository.agregarArchivos(
    idIncidencia: idIncidencia,
    request: request,
  );
}
