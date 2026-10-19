// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class CiudadanosRepositoryImpl implements CiudadanosRepository {
  final CiudadanosService ciudadanosService;
  final AuthRepository authRepository;

  CiudadanosRepositoryImpl(this.ciudadanosService, this.authRepository);

  // *********************************************************
  // 1. CREAR PERFIL CIUDADANO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<CreateCiudadanoPerfilDataModel>>>
  createCiudadanoPerfil({required CreateCiudadanoPerfilRequest request}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await ciudadanosService.createCiudadanoPerfil(
      token: token,
      request: request,
    );
  }

  // *********************************************************
  // 2. OBTENER MI PERFIL CIUDADANO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<GetCiudadanoPerfilDataModel>>>
  getMiPerfilCiudadano() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await ciudadanosService.getMiPerfilCiudadano(token: token);
  }

  // *********************************************************
  // 3. ACTUALIZAR MI PERFIL CIUDADANO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<UpdateCiudadanoPerfilDataModel>>>
  updateMiPerfilCiudadano({
    required UpdateCiudadanoPerfilRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await ciudadanosService.updateMiPerfilCiudadano(
      token: token,
      request: request,
    );
  }
}
