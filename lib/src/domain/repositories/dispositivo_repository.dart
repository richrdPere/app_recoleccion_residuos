import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class DispositivoRepository {
  /// 1. REGISTRAR DISPOSITIVO
  Future<Resource<ApiResponse<RegistrarDispositivoDataModel>>>
  registrarDispositivo({required RegistrarDispositivoRequest request});

  /// 2. OBTENER MIS DISPOSITIVOS
  Future<Resource<ApiResponse<List<MiDispositivoDataModel>>>>
  getMisDispositivos();

  /// 3. DESACTIVAR DISPOSITIVO
  Future<Resource<ApiResponse<DesactivarDispositivoDataModel>>>
  desactivarDispositivo({
    required int idDispositivo,
    DesactivarDispositivoRequest request = const DesactivarDispositivoRequest(),
  });

  /// 4. DESACTIVAR DISPOSITIVO POR TOKEN
  Future<Resource<ApiResponse<DesactivarDispositivoTokenDataModel>>>
  desactivarDispositivoPorToken({
    required DesactivarDispositivoTokenRequest request,
  });
}
