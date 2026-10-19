import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RefreshSessionUC {
  AuthRepository authRepository;
  RefreshSessionUC(this.authRepository);

  Future<Resource<ApiResponse<RefreshTokenDataModel>>> run({
    required RefreshTokenRequest request,
  }) => authRepository.refreshSession(request: request);
}
