import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class LogoutUC {
  AuthRepository authRepository;
  LogoutUC(this.authRepository);

  Future<Resource<ApiResponse<LogoutDataModel>>> run({required String token}) =>
      authRepository.logout(token: token);
}
