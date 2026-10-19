import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Agrega el import de tu clase AuthUsesCases.

import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthUsesCases authUseCases;
  bool _refreshInProgress = false;

  SessionBloc(this.authUseCases) : super(const SessionState()) {
    on<SessionStarted>(_onSessionStarted);
    on<SessionEstablished>(_onSessionEstablished);
    on<SessionLogoutRequested>(_onSessionLogoutRequested);
    on<SessionRefreshRequested>(_onSessionRefreshRequested);
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
    if (_refreshInProgress || state.isLoading || !state.isAuthenticated) {
      return;
    }

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

  // *********************************************************
  // 4. RENOVAR SESIÓN
  // *********************************************************
  Future<void> _onSessionRefreshRequested(
    SessionRefreshRequested event,
    Emitter<SessionState> emit,
  ) async {
    if (_refreshInProgress || state.isLoading || !state.isAuthenticated) {
      return;
    }

    final previousSession = state.session;
    if (previousSession == null) return;

    _refreshInProgress = true;

    // Comprueba que sigue siendo la misma sesión y que no
    // comenzó un cierre de sesión mientras esperaba la respuesta.
    bool sigueVigente() {
      return !emit.isDone &&
          state.isAuthenticated &&
          state.session?.refreshToken == previousSession.refreshToken;
    }

    try {
      final response = await authUseCases.refreshSession.run(
        request: RefreshTokenRequest(
          refreshToken: previousSession.refreshToken,
          dispositivo: 'APP_MOVIL',
        ),
      );

      if (!sigueVigente()) return;

      if (response is ErrorData<ApiResponse<RefreshTokenDataModel>>) {
        // Utiliza 401 si ese es el contrato de tu endpoint
        // para un refresh token vencido, inválido o revocado.
        if (response.statusCode == 401) {
          // Cambia primero el estado para bloquear el uso de la sesión.
          emit(
            const SessionState(
              status: SessionStatus.unauthenticated,
              errorMessage: 'Tu sesión ha expirado. Inicia sesión nuevamente.',
            ),
          );

          try {
            await authUseCases.clearUserSession.run();
          } catch (_) {
            // Permanece sin autenticar aunque falle la limpieza.
            // La persistencia debe corregirse antes de restaurarla.
          }

          return;
        }

        // Un timeout, falta de conexión o error del servidor
        // no demuestra que la sesión haya sido revocada.
        emit(
          SessionState(
            status: SessionStatus.authenticated,
            session: previousSession,
            errorMessage: response.message,
          ),
        );
        return;
      }

      if (response is! Success<ApiResponse<RefreshTokenDataModel>>) {
        emit(
          SessionState(
            status: SessionStatus.authenticated,
            session: previousSession,
            errorMessage:
                'No se recibió una respuesta válida '
                'al renovar la sesión.',
          ),
        );
        return;
      }

      final api = response.data;
      final tokens = api.data;

      if (!api.success ||
          tokens == null ||
          tokens.accessToken.trim().isEmpty ||
          tokens.refreshToken.trim().isEmpty) {
        emit(
          SessionState(
            status: SessionStatus.authenticated,
            session: previousSession,
            errorMessage:
                'El servidor no confirmó la renovación '
                'de la sesión.',
          ),
        );
        return;
      }

      final renewedSession = LoginDataModel(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        tokenType: tokens.tokenType,
        expiresIn: tokens.expiresIn,
        // El refresh no devuelve estos campos.
        refreshExpiresIn: previousSession.refreshExpiresIn,
        usuario: previousSession.usuario,
      );

      // Primero guarda los nuevos tokens.
      await authUseCases.saveUserSession.run(renewedSession);

      if (!sigueVigente()) return;

      emit(
        SessionState(
          status: SessionStatus.authenticated,
          session: renewedSession,
          successMessage: api.message,
        ),
      );
    } catch (_) {
      if (!sigueVigente()) return;

      emit(
        SessionState(
          status: SessionStatus.authenticated,
          session: previousSession,
          errorMessage: 'No se pudo completar la renovación de la sesión.',
        ),
      );
    } finally {
      _refreshInProgress = false;
    }
  }
}
