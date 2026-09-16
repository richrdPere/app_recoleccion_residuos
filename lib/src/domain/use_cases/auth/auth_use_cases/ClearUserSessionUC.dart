import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

class ClearUserSessionUC {
  AuthRepository authRepository;
  ClearUserSessionUC(this.authRepository);

  Future<void> run() => authRepository.clearUserSession();
}
