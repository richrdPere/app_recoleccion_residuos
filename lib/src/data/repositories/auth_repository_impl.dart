import 'package:app_recoleccion_residuos/src/data/datasources/local/shared/shared_pref.dart';
import 'package:app_recoleccion_residuos/src/data/datasources/remote/services/auth_service.dart';
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final SharefPref _sharedPref;

  static const String _userSessionKey = 'user';

  AuthRepositoryImpl(this._authService, this._sharedPref);

  // *********************************************************
  // 1. OBTENER SESIÓN LOCAL
  // *********************************************************
  @override
  Future<LoginDataModel?> getUserSession() async {
    try {
      final storedData = await _sharedPref.read(_userSessionKey);

      if (storedData == null) {
        return null;
      }

      if (storedData is! Map) {
        await clearUserSession();
        return null;
      }

      final sessionJson = Map<String, dynamic>.from(storedData);

      final loginData = LoginDataModel.fromJson(sessionJson);

      /*
       * Si no existe access token, la sesión almacenada
       * se considera inválida.
       */
      if (loginData.accessToken.trim().isEmpty) {
        await clearUserSession();
        return null;
      }

      return loginData;
    } catch (_) {
      /*
       * Puede ocurrir cuando existe una sesión almacenada
       * con la estructura antigua de AuthResponse.
       */
      await clearUserSession();
      return null;
    }
  }

  // *********************************************************
  // 2. GUARDAR SESIÓN LOCAL
  // *********************************************************
  @override
  Future<void> saveUserSession(LoginDataModel loginData) async {
    await _sharedPref.save(_userSessionKey, loginData.toJson());
  }

  // *********************************************************
  // 3. ELIMINAR SESIÓN LOCAL
  // *********************************************************
  @override
  Future<void> clearUserSession() async {
    await _sharedPref.remove(_userSessionKey);
  }

  // *********************************************************
  // 4. INICIAR SESIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<LoginDataModel>>> login({
    required LoginRequest request,
  }) async {
    return await _authService.login(request: request);
  }

  // *********************************************************
  // 5. CERRAR SESIÓN REMOTA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<LogoutDataModel>>> logout({
    required String token,
  }) async {
    try {
      final session = await getUserSession();

      final accessToken = session?.accessToken.trim();
      final refreshToken = token.trim();

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorData<ApiResponse<LogoutDataModel>>(
          message: 'No se encontró el token de acceso.',
        );
      }

      if (refreshToken.isEmpty) {
        return ErrorData<ApiResponse<LogoutDataModel>>(
          message: 'No se encontró el token de renovación.',
        );
      }

      return await _authService.logout(
        token: accessToken,
        request: LogoutRequest(refreshToken: refreshToken),
      );
    } catch (_) {
      return ErrorData<ApiResponse<LogoutDataModel>>(
        message: 'Ocurrió un error al procesar el cierre de sesión.',
      );
    }
  }

  // *********************************************************
  // 6. OBTENER ACCESS TOKEN
  // *********************************************************
  @override
  Future<String?> getToken() async {
    final session = await getUserSession();
    final token = session?.accessToken.trim();

    if (token == null || token.isEmpty) {
      return null;
    }

    return token;
  }

  // *********************************************************
  // 7. OBTENER REFRESH TOKEN
  // *********************************************************
  @override
  Future<String?> getRefreshToken() async {
    final session = await getUserSession();
    final refreshToken = session?.refreshToken.trim();

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    return refreshToken;
  }

  // *********************************************************
  // 8. OBTENER PERFIL DEL USUARIO AUTENTICADO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<UsuarioDataModel>>> getProfileMe() async {
    final session = await getUserSession();
    final token = session?.accessToken.trim();

    if (token == null || token.isEmpty) {
      return ErrorData<ApiResponse<UsuarioDataModel>>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return await _authService.getProfileMe(token: token);
  }
}
