import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

abstract class LoadingEvent {
  const LoadingEvent();
}

class LoadingStarted extends LoadingEvent {
  const LoadingStarted();
}

class LoadingSessionChanged extends LoadingEvent {
  final SessionState sessionState;

  const LoadingSessionChanged(this.sessionState);
}
