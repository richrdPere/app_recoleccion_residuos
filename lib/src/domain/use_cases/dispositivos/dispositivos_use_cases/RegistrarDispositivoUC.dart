import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class RegistrarDispositivoUC {
  DispositivoRepository dispositivoRepository;
  RegistrarDispositivoUC(this.dispositivoRepository);

  Future<Resource<ApiResponse<RegistrarDispositivoDataModel>>> run({
    required RegistrarDispositivoRequest request,
  }) => dispositivoRepository.registrarDispositivo(request: request);
}
