import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ResponderAsignacionUC {
  ProgramacionesRepository programacionesRepository;
  ResponderAsignacionUC(this.programacionesRepository);

  Future<Resource<ApiResponse<ResponderAsignacionDataModel>>> run({
    required int idProgramacionPersonal,
    required ResponderAsignacionRequest request,
  }) => programacionesRepository.responderAsignacion(
    idProgramacionPersonal: idProgramacionPersonal,
    request: request,
  );
}
