import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class PrefNotificationRepository {
  /// 1. OBTENER PREFERENCIAS DE NOTIFICACIÓN
  Future<Resource<ApiResponse<GetCiudadanoPreferenciasDataModel>>>
  getCiudadanoPreferencias();

  /// 2. ACTUALIZAR PREFERENCIAS DE NOTIFICACIÓN
  Future<Resource<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>>
  updateCiudadanoPreferencias({
    required UpdateCiudadanoPreferenciasRequest request,
  });
}
