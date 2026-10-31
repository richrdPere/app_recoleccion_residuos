import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetArchivoPorIdUC {
  IncidenciasRepository incidenciaRepository;
  GetArchivoPorIdUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<IncidenciaArchivoDetalleModel>>> run({
    required int idIncidencia,
    required int idArchivo,
  }) => incidenciaRepository.getArchivoPorId(
    idIncidencia: idIncidencia,
    idArchivo: idArchivo,
  );
}
