// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class IncidenciasRepositoryImpl implements IncidenciasRepository {
  final IncidenciasService incidenciasService;
  final AuthRepository authRepository;

  IncidenciasRepositoryImpl(this.incidenciasService, this.authRepository);

  // *********************************************************
  // 1. CREAR INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<CreateIncidenciaDataModel>>> createIncidencia({
    required CreateIncidenciaRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.createIncidencia(
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 2. OBTENER INCIDENCIAS PAGINADAS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciasPaginadasDataModel>>>
  getIncidenciasPaginadas({
    required IncidenciasPaginadasFilters filters,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.getIncidenciasPaginadas(
      filters: filters,
      token: token,
    );
  }

  // *********************************************************
  // 3. OBTENER INCIDENCIA POR ID
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciaDetalleModel>>> getIncidenciaById({
    required int idIncidencia,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.getIncidenciaById(
      idIncidencia: idIncidencia,
      token: token,
    );
  }

  // *********************************************************
  // 4. AGREGAR ARCHIVOS A UNA INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<List<IncidenciaArchivoCreadoModel>>>>
  agregarArchivos({
    required int idIncidencia,
    required AgregarIncidenciaArchivosRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.agregarArchivos(
      idIncidencia: idIncidencia,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 5. OBTENER ARCHIVOS POR INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<List<IncidenciaArchivoListadoModel>>>>
  getArchivosPorIncidencia({required int idIncidencia}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.getArchivosPorIncidencia(
      idIncidencia: idIncidencia,
      token: token,
    );
  }

  // *********************************************************
  // 6. OBTENER ARCHIVO POR INCIDENCIA E ID DE ARCHIVO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciaArchivoDetalleModel>>> getArchivoPorId({
    required int idIncidencia,
    required int idArchivo,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.getArchivoPorId(
      idIncidencia: idIncidencia,
      idArchivo: idArchivo,
      token: token,
    );
  }

  // *********************************************************
  // 7. ELIMINAR ARCHIVO DE INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<DeleteIncidenciaArchivoDataModel>>>
  deleteArchivo({required int idIncidencia, required int idArchivo}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.deleteArchivo(
      idIncidencia: idIncidencia,
      idArchivo: idArchivo,
      token: token,
    );
  }

  // *********************************************************
  // 8. ACTUALIZAR INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<UpdateIncidenciaDataModel>>> updateIncidencia({
    required int idIncidencia,
    required UpdateIncidenciaRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.updateIncidencia(
      idIncidencia: idIncidencia,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 9. CAMBIAR ESTADO DE INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ChangeIncidenciaEstadoDataModel>>>
  changeIncidenciaEstado({
    required int idIncidencia,
    required ChangeIncidenciaEstadoRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await incidenciasService.changeIncidenciaEstado(
      idIncidencia: idIncidencia,
      request: request,
      token: token,
    );
  }
}
