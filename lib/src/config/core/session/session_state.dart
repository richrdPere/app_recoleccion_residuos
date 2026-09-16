import 'package:app_recoleccion_residuos/src/data/models/auth/datos/usuario_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum SessionStatus {
  initial,
  restoring,
  unauthenticated,
  saving,
  authenticated,
  loggingOut,
}

class SessionState {
  final SessionStatus status;
  final LoginDataModel? session;
  final String? errorMessage;
  final String? successMessage;

  const SessionState({
    this.status = SessionStatus.initial,
    this.session,
    this.errorMessage,
    this.successMessage,
  });

  // *********************************************************
  // GETTERS
  // *********************************************************
  UsuarioDataModel? get user => session?.usuario;

  bool get isAuthenticated => session != null;

  bool get isLoading =>
      status == SessionStatus.restoring ||
      status == SessionStatus.saving ||
      status == SessionStatus.loggingOut;

  bool get isSavingSession => status == SessionStatus.saving;

  bool get isLoggingOut => status == SessionStatus.loggingOut;

  // *********************************************************
  // COPY WITH
  // *********************************************************
  SessionState copyWith({
    SessionStatus? status,
    LoginDataModel? session,
    bool clearSession = false,
    String? errorMessage,
    String? successMessage,
  }) {
    return SessionState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),

      // Los mensajes se limpian si no se proporcionan.
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
