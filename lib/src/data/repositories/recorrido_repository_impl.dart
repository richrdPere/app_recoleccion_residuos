// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class RecorridoRepositoryImpl implements RecorridoRepository {
  final RecorridoService recorridoService;
  final AuthRepository authRepository;

  RecorridoRepositoryImpl(this.recorridoService, this.authRepository);

  // *********************************************************
  // 1. INICIAR RECORRIDO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecorridoDataModel>>> iniciarRecorrido({
    required int idProgramacion,
    required IniciarRecorridoRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recorridoService.iniciarRecorrido(
      idProgramacion: idProgramacion,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 2. PAUSAR RECORRIDO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecorridoDataModel>>> pausarRecorrido({
    required int idRecorrido,
    required PausarRecorridoRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recorridoService.pausarRecorrido(
      idRecorrido: idRecorrido,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 3. REANUDAR RECORRIDO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecorridoDataModel>>> reanudarRecorrido({
    required int idRecorrido,
    required ReanudarRecorridoRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recorridoService.reanudarRecorrido(
      idRecorrido: idRecorrido,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 4. FINALIZAR RECORRIDO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecorridoDataModel>>> finalizarRecorrido({
    required int idRecorrido,
    required FinalizarRecorridoRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recorridoService.finalizarRecorrido(
      idRecorrido: idRecorrido,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 5. OBTENER RECORRIDO ACTIVO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecorridoDataModel?>>>
  getRecorridoActivo() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recorridoService.getRecorridoActivo(token: token);
  }

  // *********************************************************
  // 6. OBTENER MIS RECORRIDOS PAGINADOS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<MisRecorridosDataModel>>> getMisRecorridos({
    required int page,
    required int limit,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recorridoService.getMisRecorridos(token: token);
  }

  // *********************************************************
  // 7. OBTENER RECORRIDO POR ID
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RecorridoDataModel>>> getRecorridoById({
    required int idRecorrido,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await recorridoService.getRecorridoById(
      idRecorrido: idRecorrido,
      token: token,
    );
  }
}
