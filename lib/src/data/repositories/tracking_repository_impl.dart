// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingService trackingService;
  final AuthRepository authRepository;

  TrackingRepositoryImpl(this.trackingService, this.authRepository);

  // *********************************************************
  // 1. REGISTRAR UBICACIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegistrarUbicacionDataModel>>>
  registrarUbicacion({required RegistrarUbicacionRequest request}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await trackingService.registrarUbicacion(
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 2. REGISTRAR UBICACIONES POR LOTE
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegistrarUbicacionLoteDataModel>>>
  registrarUbicacionLote({
    required RegistrarUbicacionLoteRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await trackingService.registrarUbicacionLote(
      request: request,
      token: token,
    );
  }
}
