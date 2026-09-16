import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

class GetUserSessionUC {
  AuthRepository authRepository;
  GetUserSessionUC(this.authRepository);

  Future<LoginDataModel?> run() => authRepository.getUserSession();
}
