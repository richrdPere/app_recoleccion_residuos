import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// *********************************************************
// ESTADO DEL REGISTRO
// *********************************************************

enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  final String nombres;
  final String apellidos;
  final String dni;
  final String email;
  final String celular;

  final bool submitted;
  final RegisterStatus status;
  final String? message;

  final ApiResponse<RegisterCiudadanoDataModel>? response;

  const RegisterState({
    this.nombres = '',
    this.apellidos = '',
    this.dni = '',
    this.email = '',
    this.celular = '',
    this.submitted = false,
    this.status = RegisterStatus.initial,
    this.message,
    this.response,
  });

  // *********************************************************
  // INDICADORES
  // *********************************************************

  bool get isLoading => status == RegisterStatus.loading;

  bool get isSuccess => status == RegisterStatus.success;

  bool get isFailure => status == RegisterStatus.failure;

  bool get isValid => errors.isEmpty;

  // *********************************************************
  // VALIDACIONES
  // *********************************************************

  Map<String, String> get errors {
    final result = <String, String>{};

    final normalizedNombres = nombres.trim();
    final normalizedApellidos = apellidos.trim();
    final normalizedDni = dni.trim();
    final normalizedEmail = email.trim();
    final normalizedCelular = celular.trim();

    // NOMBRES
    if (normalizedNombres.isEmpty) {
      result['nombres'] = 'Ingresa tus nombres.';
    } else if (normalizedNombres.length > 100) {
      result['nombres'] = 'Los nombres admiten hasta 100 caracteres.';
    }

    // APELLIDOS
    if (normalizedApellidos.isEmpty) {
      result['apellidos'] = 'Ingresa tus apellidos.';
    } else if (normalizedApellidos.length > 100) {
      result['apellidos'] = 'Los apellidos admiten hasta 100 caracteres.';
    }

    // DNI
    if (!RegExp(r'^\d{8}$').hasMatch(normalizedDni)) {
      result['dni'] = 'El DNI debe contener exactamente 8 dígitos.';
    }

    // CORREO
    if (normalizedEmail.isEmpty) {
      result['email'] = 'Ingresa tu correo electrónico.';
    } else if (normalizedEmail.length > 150 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      result['email'] = 'Ingresa un correo electrónico válido.';
    }

    // CELULAR OPCIONAL
    if (normalizedCelular.isNotEmpty &&
        !RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(normalizedCelular)) {
      result['celular'] = 'Ingresa un número de celular válido.';
    }

    return result;
  }

  // *********************************************************
  // ERROR VISIBLE DE UN CAMPO
  // *********************************************************

  String? errorFor(String field) {
    return submitted ? errors[field] : null;
  }

  // *********************************************************
  // COPY WITH
  // *********************************************************

  RegisterState copyWith({
    String? nombres,
    String? apellidos,
    String? dni,
    String? email,
    String? celular,
    bool? submitted,
    RegisterStatus? status,
    String? message,
    ApiResponse<RegisterCiudadanoDataModel>? response,
    bool clearMessage = false,
    bool clearResponse = false,
  }) {
    return RegisterState(
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      dni: dni ?? this.dni,
      email: email ?? this.email,
      celular: celular ?? this.celular,
      submitted: submitted ?? this.submitted,
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      response: clearResponse ? null : response ?? this.response,
    );
  }
}
