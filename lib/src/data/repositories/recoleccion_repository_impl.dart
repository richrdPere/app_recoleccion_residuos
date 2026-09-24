// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class RecoleccionRepositoryImpl implements RecoleccionRepository {
  final RecoleccionService recoleccionService;
  final AuthRepository authRepository;

  RecoleccionRepositoryImpl(this.recoleccionService, this.authRepository);

  // *********************************************************
  // 1. REGISTRAR RECOLECCIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegistrarRecoleccionDataModel>>>
  registrarRecoleccion({required RegistrarRecoleccionRequest request}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recoleccionService.registrarRecoleccion(
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 2. REGISTRAR LOTE DE RECOLECCIONES OFFLINE
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegistrarRecoleccionLoteDataModel>>>
  registrarRecoleccionLote({
    required RegistrarRecoleccionLoteRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recoleccionService.registrarRecoleccionLote(
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 3. OBTENER PUNTOS DEL RECORRIDO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<List<PuntoRecorridoDataModel>>>>
  getPuntosRecorrido({required int idRecorrido}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recoleccionService.getPuntosRecorrido(
      idRecorrido: idRecorrido,
      token: token,
    );
  }

  // *********************************************************
  // 4. OBTENER PROGRESO DEL RECORRIDO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecorridoProgresoDataModel>>>
  getRecorridoProgreso({required int idRecorrido}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recoleccionService.getRecorridoProgreso(
      idRecorrido: idRecorrido,
      token: token,
    );
  }

  // *********************************************************
  // 5. REGISTRAR EVIDENCIA DE RECOLECCIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecoleccionEvidenciaDataModel>>>
  registrarEvidencia({
    required int idRecoleccion,
    required RegistrarEvidenciaRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recoleccionService.registrarEvidencia(
      idRecoleccion: idRecoleccion,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 6. OBTENER RECOLECCIÓN POR ID
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecoleccionDetalleDataModel>>>
  getRecoleccionById({required int idRecoleccion}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recoleccionService.getRecoleccionById(
      idRecoleccion: idRecoleccion,
      token: token,
    );
  }
}
