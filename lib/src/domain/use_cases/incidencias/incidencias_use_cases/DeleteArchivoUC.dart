import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class DeleteArchivoUC {
  IncidenciasRepository incidenciaRepository;
  DeleteArchivoUC(this.incidenciaRepository);

  Future<Resource<ApiResponse<DeleteIncidenciaArchivoDataModel>>> run({
    required int idIncidencia,
    required int idArchivo,
  }) => incidenciaRepository.deleteArchivo(
    idIncidencia: idIncidencia,
    idArchivo: idArchivo,
  );
}
