import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState {
  final LoginStatus status;
  final ApiResponse<LoginDataModel>? response;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.response,
    this.errorMessage,
  });

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginDataModel? get loginData => response?.data;
}
