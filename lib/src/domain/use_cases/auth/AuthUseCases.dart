

import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class AuthUsesCases {
  ClearUserSessionUC clearUserSession;
  GetRefreshTokenUC getRefreshToken;
  GetTokenUC getToken;
  GetUserSessionUC getUserSession;
  LoginUC login;
  LogoutUC logoutSession;
  SaveUserSessionUC saveUserSession;

  AuthUsesCases({
    required this.clearUserSession,
    required this.getRefreshToken,
    required this.getToken,
    required this.getUserSession,
    required this.login,
    required this.logoutSession,
    required this.saveUserSession,
  });
}
