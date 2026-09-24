// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class ProgramacionesRepositoryImpl implements ProgramacionesRepository {
  final ProgramacionesService programacionesService;
  final AuthRepository authRepository;

  ProgramacionesRepositoryImpl(this.programacionesService, this.authRepository);

  // *********************************************************
  // 1. OBTENER MIS ASIGNACIONES
  // *********************************************************
  @override
  Future<Resource<ApiResponse<MisAsignacionesDataModel>>> getMisAsignaciones({
    required MisAsignacionesFilters filters,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await programacionesService.getMisAsignaciones(
      filters: filters,
      token: token,
    );
  }

  // *********************************************************
  // 2. RESPONDER ASIGNACIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ResponderAsignacionDataModel>>>
  responderAsignacion({
    required int idProgramacionPersonal,
    required ResponderAsignacionRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await programacionesService.responderAsignacion(
      idProgramacionPersonal: idProgramacionPersonal,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 3. OBTENER DETALLE DE PROGRAMACIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ProgramacionDetalleDataModel>>>
  getProgramacionDetalle({required int idProgramacion}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await programacionesService.getProgramacionDetalle(
      idProgramacion: idProgramacion,
      token: token,
    );
  }
}
