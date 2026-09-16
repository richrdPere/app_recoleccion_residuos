import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class LoginEvent {
  const LoginEvent();
}

// *********************************************************
// 1. ENVIAR FORMULARIO
// *********************************************************
class LoginSubmitted extends LoginEvent {
  final LoginRequest request;

  const LoginSubmitted({required this.request});
}
