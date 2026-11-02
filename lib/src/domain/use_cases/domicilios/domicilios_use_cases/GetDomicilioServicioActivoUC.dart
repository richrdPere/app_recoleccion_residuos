import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetDomicilioServicioActivoUC {
  DomiciliosRepository domiciliosRepository;
  GetDomicilioServicioActivoUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<GetDomicilioServicioActivoDataModel>>> run({
    required int idDomicilio,
  }) =>
      domiciliosRepository.getDomicilioServicioActivo(idDomicilio: idDomicilio);
}
