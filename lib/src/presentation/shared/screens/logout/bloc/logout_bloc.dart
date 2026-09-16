import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'logout_event.dart';
import 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final SessionBloc sessionBloc;

  StreamSubscription<SessionState>? _sessionSubscription;

  bool _logoutRequested = false;
  bool _observedLoggingOut = false;

  LogoutBloc({required this.sessionBloc}) : super(const LogoutState()) {
    on<LogoutStarted>(_onStarted);
    on<LogoutSessionChanged>(_onSessionChanged);
    on<LogoutRetryRequested>(_onRetryRequested);
  }

  // *********************************************************
  // 1. INICIAR COORDINACIÓN DEL CIERRE
  // *********************************************************
  void _onStarted(LogoutStarted event, Emitter<LogoutState> emit) {
    if (_sessionSubscription != null) return;

    _sessionSubscription = sessionBloc.stream.listen((sessionState) {
      if (!isClosed) {
        add(LogoutSessionChanged(sessionState));
      }
    });

    _processSession(sessionBloc.state, emit);
  }

  // *********************************************************
  // 2. OBSERVAR CAMBIOS DE SESIÓN
  // *********************************************************
  void _onSessionChanged(
    LogoutSessionChanged event,
    Emitter<LogoutState> emit,
  ) {
    _processSession(event.sessionState, emit);
  }

  // *********************************************************
  // 3. PROCESAR ESTADO DE SESIÓN
  // *********************************************************
  void _processSession(SessionState sessionState, Emitter<LogoutState> emit) {
    // No repetir navegación después de completar el cierre.
    if (state.status == LogoutStatus.success) return;

    switch (sessionState.status) {
      case SessionStatus.authenticated:
        if (!_logoutRequested) {
          _logoutRequested = true;

          emit(const LogoutState());

          sessionBloc.add(const SessionLogoutRequested());
          return;
        }

        // SessionBloc vuelve a authenticated cuando falla
        // el cierre remoto y conserva la sesión.
        if (_observedLoggingOut) {
          emit(
            LogoutState(
              status: LogoutStatus.failure,
              errorMessage:
                  sessionState.errorMessage ??
                  'No se pudo cerrar la sesión. Inténtalo nuevamente.',
              canRetry: true,
              returnRoute: '/home',
            ),
          );
        }
        return;

      case SessionStatus.loggingOut:
        _logoutRequested = true;
        _observedLoggingOut = true;

        emit(const LogoutState());
        return;

      case SessionStatus.unauthenticated:
        final errorMessage = sessionState.errorMessage;

        if (errorMessage != null && errorMessage.isNotEmpty) {
          // Puede ocurrir si cerró la sesión remota, pero
          // falló la eliminación de los datos locales.
          emit(
            LogoutState(
              status: LogoutStatus.failure,
              errorMessage: errorMessage,
              canRetry: false,
              returnRoute: '/login',
            ),
          );
        } else {
          emit(const LogoutState(status: LogoutStatus.success));
        }
        return;

      case SessionStatus.initial:
        final errorMessage = sessionState.errorMessage;

        if (errorMessage != null && errorMessage.isNotEmpty) {
          emit(
            LogoutState(
              status: LogoutStatus.failure,
              errorMessage: errorMessage,
              canRetry: false,
              returnRoute: '/splash',
            ),
          );
        }
        return;

      case SessionStatus.restoring:
      case SessionStatus.saving:
        // Esperar a que termine la operación actual.
        return;
    }
  }

  // *********************************************************
  // 4. REINTENTAR CIERRE REMOTO
  // *********************************************************
  void _onRetryRequested(
    LogoutRetryRequested event,
    Emitter<LogoutState> emit,
  ) {
    if (state.status != LogoutStatus.failure || !state.canRetry) {
      return;
    }

    _logoutRequested = false;
    _observedLoggingOut = false;

    emit(const LogoutState());

    _processSession(sessionBloc.state, emit);
  }

  // *********************************************************
  // 5. LIBERAR SUSCRIPCIÓN
  // *********************************************************
  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();

    // SessionBloc pertenece a la aplicación.
    await super.close();
  }
}
