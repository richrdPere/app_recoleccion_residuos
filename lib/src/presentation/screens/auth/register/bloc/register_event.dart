abstract class RegisterEvent {
  const RegisterEvent();
}

// *********************************************************
// CAMPOS DEL FORMULARIO
// *********************************************************

enum RegisterField { nombres, apellidos, dni, email, celular }

// *********************************************************
// CAMBIAR CAMPO
// *********************************************************

class RegisterFieldChanged extends RegisterEvent {
  final RegisterField field;
  final String value;

  const RegisterFieldChanged({required this.field, required this.value});
}

// *********************************************************
// ENVIAR REGISTRO
// *********************************************************

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}

// *********************************************************
// RESETEAR REGISTRO
// *********************************************************
class RegisterReset extends RegisterEvent {
  const RegisterReset();
}
