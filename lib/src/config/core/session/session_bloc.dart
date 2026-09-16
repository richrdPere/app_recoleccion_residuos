import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Agrega el import de tu clase AuthUsesCases.

import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthUsesCases authUseCases;

  SessionBloc(this.authUseCases) : super(const SessionState()) {
    on<SessionStarted>(_onSessionStarted);
    on<SessionEstablished>(_onSessionEstablished);
    on<SessionLogoutRequested>(_onSessionLogoutRequested);
  }

  // *********************************************************
  // 1. RESTAURAR SESIÓN LOCAL
  // *********************************************************
  Future<void> _onSessionStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    // Restaurar solo al iniciar el BLoC.
    // También permite reintentar si falló la lectura local.
    if (state.status != SessionStatus.initial) return;

    emit(state.copyWith(status: SessionStatus.restoring));

    try {
      final session = await authUseCases.getUserSession.run();

      if (session == null) {
        emit(const SessionState(status: SessionStatus.unauthenticated));
        return;
      }

      // Validación mínima de la sesión almacenada.
      if (session.accessToken.trim().isEmpty ||
          session.refreshToken.trim().isEmpty ||
          !session.usuario.estado) {
        await authUseCases.clearUserSession.run();

        emit(
          const SessionState(
            status: SessionStatus.unauthenticated,
            errorMessage:
                'La sesión guardada no es válida. Inicia sesión nuevamente.',
          ),
        );
        return;
      }

      emit(SessionState(status: SessionStatus.authenticated, session: session));
    } catch (_) {
      emit(
        const SessionState(
          status: SessionStatus.initial,
          errorMessage:
              'No se pudo recuperar la sesión guardada. Inténtalo nuevamente.',
        ),
      );
    }
  }

  // *********************************************************
  // 2. GUARDAR Y ACTIVAR SESIÓN
  // *********************************************************
  Future<void> _onSessionEstablished(
    SessionEstablished event,
    Emitter<SessionState> emit,
  ) async {
    if (state.isLoading || state.isAuthenticated) return;

    final loginData = event.loginData;

    if (loginData.accessToken.trim().isEmpty ||
        loginData.refreshToken.trim().isEmpty ||
        !loginData.usuario.estado) {
      emit(
        const SessionState(
          status: SessionStatus.unauthenticated,
          errorMessage: 'Los datos de la sesión no son válidos.',
        ),
      );
      return;
    }

    emit(const SessionState(status: SessionStatus.saving));

    try {
      await authUseCases.saveUserSession.run(loginData);

      emit(
        SessionState(
          status: SessionStatus.authenticated,
          session: loginData,
          successMessage: 'Inicio de sesión realizado correctamente.',
        ),
      );
    } catch (_) {
      emit(
        const SessionState(
          status: SessionStatus.unauthenticated,
          errorMessage:
              'No se pudo guardar la sesión en este dispositivo. '
              'Inténtalo nuevamente.',
        ),
      );
    }
  }

  // *********************************************************
  // 3. CERRAR SESIÓN
  // *********************************************************
  Future<void> _onSessionLogoutRequested(
    SessionLogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    if (state.isLoading || !state.isAuthenticated) return;

    emit(state.copyWith(status: SessionStatus.loggingOut));

    try {
      // 1. OBTENER REFRESH TOKEN
      final refreshToken = await authUseCases.getRefreshToken.run();

      if (refreshToken == null || refreshToken.trim().isEmpty) {
        emit(
          state.copyWith(
            status: SessionStatus.authenticated,
            errorMessage:
                'No se encontró el refresh token para cerrar la sesión.',
          ),
        );
        return;
      }

      // 2. CERRAR SESIÓN REMOTA
      final response = await authUseCases.logoutSession.run(
        token: refreshToken,
      );

      if (response is ErrorData<ApiResponse<LogoutDataModel>>) {
        emit(
          state.copyWith(
            status: SessionStatus.authenticated,
            errorMessage: response.message,
          ),
        );
        return;
      }

      if (response is! Success<ApiResponse<LogoutDataModel>>) {
        emit(
          state.copyWith(
            status: SessionStatus.authenticated,
            errorMessage:
                'No se recibió una respuesta válida al cerrar sesión.',
          ),
        );
        return;
      }

      final apiResponse = response.data;
      final logoutData = apiResponse.data;

      // Acepta también el cierre repetido de una sesión.
      if (logoutData == null ||
          (!logoutData.sessionClosed && !logoutData.alreadyClosed)) {
        emit(
          state.copyWith(
            status: SessionStatus.authenticated,
            errorMessage: 'El servidor no confirmó el cierre de la sesión.',
          ),
        );
        return;
      }

      // 3. ELIMINAR SESIÓN LOCAL
      try {
        await authUseCases.clearUserSession.run();
      } catch (_) {
        // El servidor ya cerró la sesión: no se vuelve a marcar
        // como autenticada aunque falle la limpieza local.
        emit(
          const SessionState(
            status: SessionStatus.unauthenticated,
            errorMessage:
                'La sesión se cerró en el servidor, pero no se pudieron '
                'eliminar los datos guardados en este dispositivo.',
          ),
        );
        return;
      }

      // 4. SESIÓN CERRADA
      emit(
        SessionState(
          status: SessionStatus.unauthenticated,
          successMessage: apiResponse.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SessionStatus.authenticated,
          errorMessage: 'Ocurrió un error al cerrar sesión.',
        ),
      );
    }
  }
}
