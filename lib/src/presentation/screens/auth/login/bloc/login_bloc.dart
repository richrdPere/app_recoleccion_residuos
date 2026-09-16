import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Use cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthUsesCases authUseCases;

  LoginBloc(this.authUseCases) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  // *********************************************************
  // 1. INICIAR SESIÓN REMOTA
  // *********************************************************
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Evita solicitudes simultáneas.
    if (state.isSubmitting) return;

    final request = event.request;

    // 1. VALIDAR FORMULARIO
    if (request.username.trim().isEmpty) {
      emit(
        const LoginState(
          status: LoginStatus.failure,
          errorMessage: 'Ingresa tu usuario.',
        ),
      );
      return;
    }

    // La contraseña se valida sin modificar sus espacios.
    if (request.password.isEmpty) {
      emit(
        const LoginState(
          status: LoginStatus.failure,
          errorMessage: 'Ingresa tu contraseña.',
        ),
      );
      return;
    }

    // 2. ESTADO DE CARGA
    emit(const LoginState(status: LoginStatus.submitting));

    try {
      // 3. EJECUTAR LOGIN
      final result = await authUseCases.login.run(request: request);

      // 4. ERROR DEL SERVICE
      if (result is ErrorData<ApiResponse<LoginDataModel>>) {
        emit(
          LoginState(status: LoginStatus.failure, errorMessage: result.message),
        );
        return;
      }

      // 5. VALIDAR RESPUESTA
      if (result is! Success<ApiResponse<LoginDataModel>>) {
        emit(
          const LoginState(
            status: LoginStatus.failure,
            errorMessage:
                'No se recibió una respuesta válida al iniciar sesión.',
          ),
        );
        return;
      }

      final apiResponse = result.data;
      final loginData = apiResponse.data;

      if (loginData == null ||
          loginData.accessToken.trim().isEmpty ||
          loginData.refreshToken.trim().isEmpty ||
          !loginData.usuario.estado) {
        emit(
          const LoginState(
            status: LoginStatus.failure,
            errorMessage:
                'No se recibieron datos válidos para iniciar la sesión.',
          ),
        );
        return;
      }

      // 6. LOGIN REMOTO EXITOSO
      // SessionBloc se encargará de guardar la sesión.
      emit(LoginState(status: LoginStatus.success, response: apiResponse));
    } catch (_) {
      emit(
        const LoginState(
          status: LoginStatus.failure,
          errorMessage: 'Ocurrió un error al iniciar sesión.',
        ),
      );
    }
  }
}
