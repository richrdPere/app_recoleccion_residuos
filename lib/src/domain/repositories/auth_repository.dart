import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class AuthRepository {
  /// 1. OBTENER SESIÓN LOCAL
  Future<LoginDataModel?> getUserSession();

  /// 2. GUARDAR SESIÓN LOCAL
  Future<void> saveUserSession(LoginDataModel loginData);

  /// 3. ELIMINAR SESIÓN LOCAL
  Future<void> clearUserSession();

  /// 4. INICIAR SESIÓN
  Future<Resource<ApiResponse<LoginDataModel>>> login({
    required LoginRequest request,
  });

  /// 5. CERRAR SESIÓN REMOTA
  Future<Resource<ApiResponse<LogoutDataModel>>> logout({
    required String token,
  });

  /// 6. OBTENER ACCESS TOKEN
  Future<String?> getToken();

  /// 7. OBTENER REFRESH TOKEN
  Future<String?> getRefreshToken();

  /// 8. OBTENER PERFIL USUARIO
  Future<Resource<ApiResponse<UsuarioDataModel>>> getProfileMe();
}
