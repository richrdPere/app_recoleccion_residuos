import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetPuntosRecorridoUC {
  RecoleccionRepository recoleccionRepository;
  GetPuntosRecorridoUC(this.recoleccionRepository);

  Future<Resource<ApiResponse<List<PuntoRecorridoDataModel>>>> run({
    required int idRecorrido,
  }) => recoleccionRepository.getPuntosRecorrido(idRecorrido: idRecorrido);
}
