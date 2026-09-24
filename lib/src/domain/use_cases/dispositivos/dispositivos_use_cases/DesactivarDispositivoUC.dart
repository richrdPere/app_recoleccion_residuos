import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class DesactivarDispositivoUC {
  DispositivoRepository dispositivoRepository;
  DesactivarDispositivoUC(this.dispositivoRepository);

  Future<Resource<ApiResponse<DesactivarDispositivoDataModel>>> run({
    required int idDispositivo,
    DesactivarDispositivoRequest request = const DesactivarDispositivoRequest(),
  }) => dispositivoRepository.desactivarDispositivo(
    idDispositivo: idDispositivo,
    request: request,
  );
}
