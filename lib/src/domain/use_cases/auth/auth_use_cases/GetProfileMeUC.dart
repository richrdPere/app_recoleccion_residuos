import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories/auth_repository.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetProfileMeUC {
  AuthRepository authRepository;
  GetProfileMeUC(this.authRepository);

  Future<Resource<ApiResponse<UsuarioDataModel>>> run() =>
      authRepository.getProfileMe();
}
