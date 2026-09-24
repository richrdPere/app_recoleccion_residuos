import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetProgramacionDetalleUC {
  ProgramacionesRepository programacionesRepository;
  GetProgramacionDetalleUC(this.programacionesRepository);

  Future<Resource<ApiResponse<ProgramacionDetalleDataModel>>> run({
    required int idProgramacion,
  }) => programacionesRepository.getProgramacionDetalle(
    idProgramacion: idProgramacion,
  );
}
