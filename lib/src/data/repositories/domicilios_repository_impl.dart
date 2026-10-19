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
  @override
  Future<Resource<ApiResponse<GetDomicilioCronogramaDataModel>>>
  getDomicilioCronograma({required int idDomicilio}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return domiciliosService.getDomicilioCronograma(
      token: token,
      idDomicilio: idDomicilio,
    );
  }

  // *********************************************************
  // 6. ELIMINAR DOMICILIO CIUDADANO
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
}
