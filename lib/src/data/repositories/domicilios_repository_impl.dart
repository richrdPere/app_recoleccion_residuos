// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class DomiciliosRepositoryImpl implements DomiciliosRepository {
  final DomiciliosService domiciliosService;
  final AuthRepository authRepository;

  DomiciliosRepositoryImpl(this.domiciliosService, this.authRepository);

  // *********************************************************
  // 1. REGISTRAR DOMICILIO CIUDADANO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<CreateCiudadanoDomicilioDataModel>>>
  createCiudadanoDomicilio({
    required CreateCiudadanoDomicilioRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await domiciliosService.createCiudadanoDomicilio(
      token: token,
      request: request,
    );
  }

  // *********************************************************
  // 2. OBTENER MIS DOMICILIOS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<List<GetMisDomiciliosDataModel>>>>
  getMisDomicilios({bool incluirInactivos = false}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await domiciliosService.getMisDomicilios(
      token: token,
      incluirInactivos: incluirInactivos,
    );
  }

  // *********************************************************
  // 3. ACTUALIZAR DOMICILIO CIUDADANO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<UpdateCiudadanoDomicilioDataModel>>>
  updateCiudadanoDomicilio({
    required int idDomicilio,
    required UpdateCiudadanoDomicilioRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await domiciliosService.updateCiudadanoDomicilio(
      token: token,
      idDomicilio: idDomicilio,
      request: request,
    );
  }

  // *********************************************************
  // 4. ESTABLECER DOMICILIO PRINCIPAL
  // *********************************************************
  @override
  Future<Resource<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>>
  setPrincipalCiudadanoDomicilio({required int idDomicilio}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await domiciliosService.setPrincipalCiudadanoDomicilio(
      token: token,
      idDomicilio: idDomicilio,
    );
  }

  // *********************************************************
  // 5. OBTENER CRONOGRAMA DEL DOMICILIO
  // *********************************************************
  // *********************************************************
  // 5. OBTENER CRONOGRAMA DEL DOMICILIO
  // *********************************************************

  @override
  Future<Resource<ApiResponse<GetDomicilioCronogramaDataModel>>>
  getDomicilioCronograma({
    required int idDomicilio,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final token = await authRepository.getToken();

    if (token == null || token.trim().isEmpty) {
      return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
        message: 'No existe una sesión iniciada.',
        statusCode: 401,
      );
    }

    return domiciliosService.getDomicilioCronograma(
      token: token,
      idDomicilio: idDomicilio,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
  }

  // *********************************************************
  // 6. OBTENER SERVICIO ACTIVO DEL DOMICILIO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<GetDomicilioServicioActivoDataModel>>>
  getDomicilioServicioActivo({required int idDomicilio}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await domiciliosService.getDomicilioServicioActivo(
      token: token,
      idDomicilio: idDomicilio,
    );
  }

  // *********************************************************
  // 7. ELIMINAR DOMICILIO CIUDADANO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<DeleteCiudadanoDomicilioDataModel>>>
  deleteCiudadanoDomicilio({required int idDomicilio}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return domiciliosService.deleteCiudadanoDomicilio(
      token: token,
      idDomicilio: idDomicilio,
    );
  }

  // *********************************************************
  // 8. RESOLVER COBERTURA DEL DOMICILIO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ResolverCoberturaDataModel>>> resolverCobertura({
    required ResolverCoberturaRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await domiciliosService.resolverCobertura(
      token: token,
      request: request,
    );
  }

  // *********************************************************
  // 9. CAMBIAR ESTADO DEL DOMICILIO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<UpdateCiudadanoDomicilioDataModel>>>
  changeEstadoCiudadanoDomicilio({
    required int idDomicilio,
    required bool activo,
  }) async {
    final token = await authRepository.getToken();

    if (token == null || token.trim().isEmpty) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message: 'No existe una sesión iniciada.',
        statusCode: 401,
      );
    }

    return await domiciliosService.changeEstadoCiudadanoDomicilio(
      token: token,
      idDomicilio: idDomicilio,
      activo: activo,
    );
  }
}
