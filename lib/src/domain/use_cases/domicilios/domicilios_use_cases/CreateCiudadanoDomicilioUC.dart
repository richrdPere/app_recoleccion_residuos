import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class CreateCiudadanoDomicilioUC {
  DomiciliosRepository domiciliosRepository;
  CreateCiudadanoDomicilioUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<CreateCiudadanoDomicilioDataModel>>> run({
    required CreateCiudadanoDomicilioRequest request,
  }) => domiciliosRepository.createCiudadanoDomicilio(request: request);
}
