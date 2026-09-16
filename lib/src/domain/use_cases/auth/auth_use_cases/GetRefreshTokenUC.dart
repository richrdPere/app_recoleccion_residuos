import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

class GetRefreshTokenUC {
  AuthRepository authRepository;
  GetRefreshTokenUC(this.authRepository);

  Future<String?> run() => authRepository.getRefreshToken();
}
