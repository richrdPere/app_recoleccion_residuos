import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class LoginUC {
  AuthRepository authRepository;
  LoginUC(this.authRepository);

  Future<Resource<ApiResponse<LoginDataModel>>> run({
    required LoginRequest request,
  }) => authRepository.login(request: request);
}
