import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

class GetTokenUC {
  AuthRepository authRepository;
  GetTokenUC(this.authRepository);

  Future<String?> run() => authRepository.getToken();
}
