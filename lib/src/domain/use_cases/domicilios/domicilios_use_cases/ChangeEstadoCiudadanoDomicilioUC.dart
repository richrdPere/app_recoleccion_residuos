import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ChangeEstadoCiudadanoDomicilioUC {
  final DomiciliosRepository domiciliosRepository;

  ChangeEstadoCiudadanoDomicilioUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<UpdateCiudadanoDomicilioDataModel>>> run({
    required int idDomicilio,
    required bool activo,
  }) {
    return domiciliosRepository.changeEstadoCiudadanoDomicilio(
      idDomicilio: idDomicilio,
      activo: activo,
    );
  }
}
