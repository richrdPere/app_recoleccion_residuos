import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

class SaveUserSessionUC {
  AuthRepository authRepository;
  SaveUserSessionUC(this.authRepository);

  Future<void> run(LoginDataModel loginData) =>
      authRepository.saveUserSession(loginData);
}
