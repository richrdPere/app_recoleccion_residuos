import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class CiudadanosRepository {
  /// 1. CREAR PERFIL CIUDADANO
  Future<Resource<ApiResponse<CreateCiudadanoPerfilDataModel>>>
  createCiudadanoPerfil({required CreateCiudadanoPerfilRequest request});

  /// 2. OBTENER MI PERFIL CIUDADANO
  Future<Resource<ApiResponse<GetCiudadanoPerfilDataModel>>>
  getMiPerfilCiudadano();

  /// 3. ACTUALIZAR MI PERFIL CIUDADANO
  Future<Resource<ApiResponse<UpdateCiudadanoPerfilDataModel>>>
  updateMiPerfilCiudadano({required UpdateCiudadanoPerfilRequest request});
}
