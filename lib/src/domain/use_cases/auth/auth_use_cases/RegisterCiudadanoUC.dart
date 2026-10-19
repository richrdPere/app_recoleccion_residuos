import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RegisterCiudadanoUC {
  AuthRepository authRepository;
  RegisterCiudadanoUC(this.authRepository);

  Future<Resource<ApiResponse<RegisterCiudadanoDataModel>>> run({
    required RegisterCiudadanoRequest request,
  }) => authRepository.registerCiudadano(request: request);
}
