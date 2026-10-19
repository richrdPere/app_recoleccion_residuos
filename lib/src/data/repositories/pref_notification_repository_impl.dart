// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class PrefNotificationRepositoryImpl implements PrefNotificationRepository {
  final PrefNotificationService prefNotificationService;
  final AuthRepository authRepository;

  PrefNotificationRepositoryImpl(
    this.prefNotificationService,
    this.authRepository,
  );

  // *********************************************************
  // 1. OBTENER PREFERENCIAS DE NOTIFICACIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<GetCiudadanoPreferenciasDataModel>>>
  getCiudadanoPreferencias() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await prefNotificationService.getCiudadanoPreferencias(token: token);
  }

  // *********************************************************
  // 2. ACTUALIZAR PREFERENCIAS DE NOTIFICACIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>>
  updateCiudadanoPreferencias({
    required UpdateCiudadanoPreferenciasRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await prefNotificationService.updateCiudadanoPreferencias(
      token: token,
      request: request,
    );
  }
}
