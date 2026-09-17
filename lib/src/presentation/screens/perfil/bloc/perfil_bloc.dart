import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Use cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/perfil/bloc/perfil_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/perfil/bloc/perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final AuthUsesCases authUseCases;

  // Permite descartar una respuesta pendiente si se limpia
  // el perfil mientras la petición todavía está en curso.
  int _requestVersion = 0;

  PerfilBloc(this.authUseCases) : super(const PerfilState()) {
    on<PerfilRequested>(_onPerfilRequested);
    on<PerfilCleared>(_onPerfilCleared);
  }

  // *********************************************************
  // 1. OBTENER PERFIL
  // *********************************************************
  Future<void> _onPerfilRequested(
    PerfilRequested event,
    Emitter<PerfilState> emit,
  ) async {
    // Evitar consultas simultáneas.
    if (state.isBusy) return;

    final requestVersion = ++_requestVersion;
    final previousResponse = state.response;

    emit(
      PerfilState(
        status: state.hasData ? PerfilStatus.refreshing : PerfilStatus.loading,
        response: previousResponse,
      ),
    );

    try {
      // El repository obtiene el access token.
      final result = await authUseCases.getProfileMeUC.run();

      if (emit.isDone || requestVersion != _requestVersion) {
        return;
      }

      // 1. ERROR DEL SERVICE O REPOSITORY
      if (result is ErrorData<ApiResponse<UsuarioDataModel>>) {
        emit(
          PerfilState(
            status: PerfilStatus.failure,
            response: previousResponse,
            errorMessage: result.message,
            statusCode: result.statusCode,
          ),
        );
        return;
      }

      // 2. RESPUESTA INESPERADA
      if (result is! Success<ApiResponse<UsuarioDataModel>>) {
        emit(
          PerfilState(
            status: PerfilStatus.failure,
            response: previousResponse,
            errorMessage:
                'No se recibió una respuesta válida al consultar tu perfil.',
          ),
        );
        return;
      }

      final apiResponse = result.data;

      // 3. VALIDAR DATOS
      if (apiResponse.data == null) {
        emit(
          PerfilState(
            status: PerfilStatus.failure,
            response: previousResponse,
            errorMessage: 'El servidor no devolvió los datos de tu perfil.',
          ),
        );
        return;
      }

      // 4. PERFIL OBTENIDO
      emit(PerfilState(status: PerfilStatus.success, response: apiResponse));
    } catch (_) {
      if (emit.isDone || requestVersion != _requestVersion) {
        return;
      }

      emit(
        PerfilState(
          status: PerfilStatus.failure,
          response: previousResponse,
          errorMessage: 'Ocurrió un error al consultar tu perfil.',
        ),
      );
    }
  }

  // *********************************************************
  // 2. LIMPIAR PERFIL
  // *********************************************************
  void _onPerfilCleared(PerfilCleared event, Emitter<PerfilState> emit) {
    // Una respuesta de la petición anterior ya no debe
    // volver a colocar información en el estado.
    _requestVersion++;

    emit(const PerfilState());
  }
}
