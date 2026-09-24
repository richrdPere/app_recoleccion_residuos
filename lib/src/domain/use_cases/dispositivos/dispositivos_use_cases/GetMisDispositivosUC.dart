import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GetMisDispositivosUC {
  DispositivoRepository dispositivoRepository;
  GetMisDispositivosUC(this.dispositivoRepository);

  Future<Resource<ApiResponse<List<MiDispositivoDataModel>>>> run() =>
      dispositivoRepository.getMisDispositivos();
}
