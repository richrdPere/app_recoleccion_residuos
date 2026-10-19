import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class SetPrincipalCiudadanoDomicilioUC {
  DomiciliosRepository domiciliosRepository;
  SetPrincipalCiudadanoDomicilioUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>> run({
    required int idDomicilio,
  }) => domiciliosRepository.setPrincipalCiudadanoDomicilio(
    idDomicilio: idDomicilio,
  );
}
