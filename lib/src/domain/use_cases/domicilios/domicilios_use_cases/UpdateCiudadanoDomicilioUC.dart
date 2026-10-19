import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class UpdateCiudadanoDomicilioUC {
  DomiciliosRepository domiciliosRepository;
  UpdateCiudadanoDomicilioUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<UpdateCiudadanoDomicilioDataModel>>> run({
    required int idDomicilio,
    required UpdateCiudadanoDomicilioRequest request,
  }) => domiciliosRepository.updateCiudadanoDomicilio(
    idDomicilio: idDomicilio,
    request: request,
  );
}
