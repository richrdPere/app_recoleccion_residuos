import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

abstract class SplashEvent {
  const SplashEvent();
}

class SplashStarted extends SplashEvent {
  const SplashStarted();
}

class SplashSessionChanged extends SplashEvent {
  final SessionState sessionState;

  const SplashSessionChanged(this.sessionState);
}

class SplashRetryRequested extends SplashEvent {
  const SplashRetryRequested();
}
