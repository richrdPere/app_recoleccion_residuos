import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class ProgramacionesRepository {
  /// 1. OBTENER MIS ASIGNACIONES
  Future<Resource<ApiResponse<MisAsignacionesDataModel>>> getMisAsignaciones({
    required MisAsignacionesFilters filters,
  });

  /// 2. RESPONDER ASIGNACIÓN
  Future<Resource<ApiResponse<ResponderAsignacionDataModel>>>
  responderAsignacion({
    required int idProgramacionPersonal,
    required ResponderAsignacionRequest request,
  });

  /// 3. OBTENER DETALLE DE PROGRAMACIÓN
  Future<Resource<ApiResponse<ProgramacionDetalleDataModel>>>
  getProgramacionDetalle({required int idProgramacion});
}
