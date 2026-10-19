import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetMisDomiciliosUC {
  DomiciliosRepository domiciliosRepository;
  GetMisDomiciliosUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<List<GetMisDomiciliosDataModel>>>> run({
    bool incluirInactivos = false,
  }) =>
      domiciliosRepository.getMisDomicilios(incluirInactivos: incluirInactivos);
}
