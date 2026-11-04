import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetDomicilioCronogramaUC {
  DomiciliosRepository domiciliosRepository;
  GetDomicilioCronogramaUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<GetDomicilioCronogramaDataModel>>> run({
    required int idDomicilio,
    String? fechaDesde,
    String? fechaHasta,
  }) => domiciliosRepository.getDomicilioCronograma(
    idDomicilio: idDomicilio,
    fechaDesde: fechaDesde,
    fechaHasta: fechaHasta,
  );
}
