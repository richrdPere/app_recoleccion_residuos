import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

abstract class LogoutEvent {
  const LogoutEvent();
}

class LogoutStarted extends LogoutEvent {
  const LogoutStarted();
}

class LogoutSessionChanged extends LogoutEvent {
  final SessionState sessionState;

  const LogoutSessionChanged(this.sessionState);
}

class LogoutRetryRequested extends LogoutEvent {
  const LogoutRetryRequested();
}
