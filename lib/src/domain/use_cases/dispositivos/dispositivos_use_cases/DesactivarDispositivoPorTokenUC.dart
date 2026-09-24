import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class DesactivarDispositivoPorTokenUC {
  DispositivoRepository dispositivoRepository;
  DesactivarDispositivoPorTokenUC(this.dispositivoRepository);

  Future<Resource<ApiResponse<DesactivarDispositivoTokenDataModel>>> run({
    required DesactivarDispositivoTokenRequest request,
  }) => dispositivoRepository.desactivarDispositivoPorToken(request: request);
}
