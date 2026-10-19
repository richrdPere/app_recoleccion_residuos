import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Uses cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthUsesCases authUseCases;

  RegisterBloc(this.authUseCases) : super(const RegisterState()) {
    on<RegisterFieldChanged>(_onFieldChanged);
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterReset>(_onReset);
  }

  // *********************************************************
  // 1. ACTUALIZAR CAMPO
  // *********************************************************

  void _onFieldChanged(
    RegisterFieldChanged event,
    Emitter<RegisterState> emit,
  ) {
    if (state.isLoading || state.isSuccess) {
      return;
    }

    final nextState = state.copyWith(
      status: RegisterStatus.initial,
      clearMessage: true,
      clearResponse: true,
    );

    switch (event.field) {
      case RegisterField.nombres:
        emit(nextState.copyWith(nombres: event.value));
        break;

      case RegisterField.apellidos:
        emit(nextState.copyWith(apellidos: event.value));
        break;

      case RegisterField.dni:
        emit(nextState.copyWith(dni: event.value));
        break;

      case RegisterField.email:
        emit(nextState.copyWith(email: event.value));
        break;

      case RegisterField.celular:
        emit(nextState.copyWith(celular: event.value));
        break;
    }
  }

  // *********************************************************
  // 2. REGISTRAR CIUDADANO
  // *********************************************************

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    // Evitar solicitudes simultáneas y nuevos envíos tras el éxito.
    if (state.isLoading || state.isSuccess) {
      return;
    }

    final validatedState = state.copyWith(
      submitted: true,
      status: RegisterStatus.initial,
      clearMessage: true,
      clearResponse: true,
    );

    // VALIDAR FORMULARIO
    if (!validatedState.isValid) {
      emit(validatedState);
      return;
    }

    // CONSTRUIR REQUEST
    final dni = validatedState.dni.trim();
    final celular = validatedState.celular.trim();

    final request = RegisterCiudadanoRequest(
      nombres: validatedState.nombres.trim(),
      apellidos: validatedState.apellidos.trim(),
      tipoDocumento: 'DNI',
      numeroDocumento: dni,
      celular: celular.isEmpty ? null : celular,
      email: validatedState.email.trim().toLowerCase(),

      // REGLA SOLICITADA:
      // El DNI se usa como usuario y contraseña.
      username: dni,
      password: dni,
    );

    emit(validatedState.copyWith(status: RegisterStatus.loading));

    try {
      final resource = await authUseCases.registerCiudadano.run(
        request: request,
      );

      if (emit.isDone) {
        return;
      }

      // RESPUESTA EXITOSA
      if (resource is Success<ApiResponse<RegisterCiudadanoDataModel>>) {
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            response: resource.data,
            message:
                'Cuenta ciudadana registrada correctamente. '
                'Ya puedes iniciar sesión.',
          ),
        );
        return;
      }

      // ERROR DEL SERVICE / BACKEND
      if (resource is ErrorData<ApiResponse<RegisterCiudadanoDataModel>>) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            message: resource.message,
            clearResponse: true,
          ),
        );
        return;
      }

      // RESPUESTA INESPERADA
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          message: 'No se recibió un resultado válido del registro.',
          clearResponse: true,
        ),
      );
    } catch (_) {
      if (emit.isDone) {
        return;
      }

      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          message:
              'No se pudo confirmar el registro. '
              'Intenta iniciar sesión antes de registrarte nuevamente.',
          clearResponse: true,
        ),
      );
    }
  }

  // *********************************************************
  // 3. REINICIAR FORMULARIO
  // *********************************************************

  void _onReset(RegisterReset event, Emitter<RegisterState> emit) {
    if (state.isLoading) return;

    emit(const RegisterState());
  }
}
