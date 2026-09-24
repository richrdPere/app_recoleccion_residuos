import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class TrackingRepository {
  /// 1. REGISTRAR UBICACIÓN
  Future<Resource<ApiResponse<RegistrarUbicacionDataModel>>>
  registrarUbicacion({required RegistrarUbicacionRequest request});

  /// 2. REGISTRAR UBICACIONES POR LOTE
  Future<Resource<ApiResponse<RegistrarUbicacionLoteDataModel>>>
  registrarUbicacionLote({required RegistrarUbicacionLoteRequest request});
}
