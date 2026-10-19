import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class CreateCiudadanoPerfilUC {
  CiudadanosRepository ciudadanosRepository;
  CreateCiudadanoPerfilUC(this.ciudadanosRepository);

  Future<Resource<ApiResponse<CreateCiudadanoPerfilDataModel>>> run({
    required CreateCiudadanoPerfilRequest request,
  }) => ciudadanosRepository.createCiudadanoPerfil(request: request);
}
