import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class SessionEvent {
  const SessionEvent();
}

// *********************************************************
// 1. RESTAURAR SESIÓN LOCAL
// *********************************************************
class SessionStarted extends SessionEvent {
  const SessionStarted();
}

// *********************************************************
// 2. GUARDAR Y ACTIVAR SESIÓN
// *********************************************************
class SessionEstablished extends SessionEvent {
  final LoginDataModel loginData;

  const SessionEstablished({required this.loginData});
}

// *********************************************************
// 3. CERRAR SESIÓN
// *********************************************************
class SessionLogoutRequested extends SessionEvent {
  const SessionLogoutRequested();
}
