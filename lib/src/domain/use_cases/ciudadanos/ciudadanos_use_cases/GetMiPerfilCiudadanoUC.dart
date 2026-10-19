import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetMiPerfilCiudadanoUC {
  CiudadanosRepository ciudadanosRepository;
  GetMiPerfilCiudadanoUC(this.ciudadanosRepository);

  Future<Resource<ApiResponse<GetCiudadanoPerfilDataModel>>> run() =>
      ciudadanosRepository.getMiPerfilCiudadano();
}
