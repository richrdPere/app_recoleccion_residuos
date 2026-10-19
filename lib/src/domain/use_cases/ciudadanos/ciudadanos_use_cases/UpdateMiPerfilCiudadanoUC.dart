import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class UpdateMiPerfilCiudadanoUC {
  CiudadanosRepository ciudadanosRepository;
  UpdateMiPerfilCiudadanoUC(this.ciudadanosRepository);

  Future<Resource<ApiResponse<UpdateCiudadanoPerfilDataModel>>> run({
    required UpdateCiudadanoPerfilRequest request,
  }) => ciudadanosRepository.updateMiPerfilCiudadano(request: request);
}
