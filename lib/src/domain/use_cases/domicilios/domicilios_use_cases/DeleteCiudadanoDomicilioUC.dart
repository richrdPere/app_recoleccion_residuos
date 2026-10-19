import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class DeleteCiudadanoDomicilioUC {
  DomiciliosRepository domiciliosRepository;
  DeleteCiudadanoDomicilioUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<DeleteCiudadanoDomicilioDataModel>>> run({
    required int idDomicilio,
  }) => domiciliosRepository.deleteCiudadanoDomicilio(idDomicilio: idDomicilio);
}
