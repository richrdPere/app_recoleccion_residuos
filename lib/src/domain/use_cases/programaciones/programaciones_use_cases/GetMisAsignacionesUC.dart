import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetMisAsignacionesUC {
  ProgramacionesRepository programacionesRepository;
  GetMisAsignacionesUC(this.programacionesRepository);

  Future<Resource<ApiResponse<MisAsignacionesDataModel>>> run({
    required MisAsignacionesFilters filters,
  }) => programacionesRepository.getMisAsignaciones(filters: filters);
}
