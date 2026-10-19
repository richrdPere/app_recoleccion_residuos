import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Use cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'ciudadano_cuenta_event.dart';
import 'ciudadano_cuenta_state.dart';

class CiudadanoCuentaBloc
    extends Bloc<CiudadanoCuentaEvent, CiudadanoCuentaState> {
  final CiudadanosUseCases ciudadanosUseCases;

  int _operationId = 0;

  CiudadanoCuentaBloc(this.ciudadanosUseCases)
    : super(const CiudadanoCuentaState()) {
    on<CiudadanoCuentaRequested>(_onRequested);
    on<CiudadanoCuentaCreateSubmitted>(_onCreateSubmitted);
    on<CiudadanoCuentaUpdateSubmitted>(_onUpdateSubmitted);
    on<CiudadanoCuentaReset>(_onReset);
  }

  // *********************************************************
  // 1. LIMPIAR ESTADO
  // *********************************************************

  void _onReset(
    CiudadanoCuentaReset event,
    Emitter<CiudadanoCuentaState> emit,
  ) {
    _operationId++;

    emit(const CiudadanoCuentaState());
  }

  // *********************************************************
  // 2. CONSULTAR PERFIL
  // *********************************************************

  Future<void> _onRequested(
    CiudadanoCuentaRequested event,
    Emitter<CiudadanoCuentaState> emit,
  ) async {
    if (state.isBusy) return;

    final operationId = ++_operationId;

    emit(
      state.copyWith(
        status: CiudadanoCuentaStatus.loading,
        clearMessages: true,
      ),
    );

    await _fetchProfile(emit, operationId: operationId);
  }

  // *********************************************************
  // 3. CREAR PERFIL
  // *********************************************************

  Future<void> _onCreateSubmitted(
    CiudadanoCuentaCreateSubmitted event,
    Emitter<CiudadanoCuentaState> emit,
  ) async {
    // Solo crear después de confirmar que falta el perfil.
    if (state.isBusy || !state.needsProfile) return;

    final operationId = ++_operationId;

    emit(
      state.copyWith(
        status: CiudadanoCuentaStatus.creating,
        clearMessages: true,
      ),
    );

    try {
      final resource = await ciudadanosUseCases.createCiudadanoPerfil.run(
        request: event.request,
      );

      if (!_isCurrent(emit, operationId)) return;

      if (resource is ErrorData<ApiResponse<CreateCiudadanoPerfilDataModel>>) {
        _emitFailure(
          emit,
          message: resource.message,
          statusCode: resource.statusCode,
        );
        return;
      }

      if (resource is! Success<ApiResponse<CreateCiudadanoPerfilDataModel>>) {
        _emitFailure(
          emit,
          message: 'No se recibió un resultado válido del registro.',
        );
        return;
      }

      final api = resource.data;

      if (!api.success || api.data == null) {
        _emitFailure(
          emit,
          message: 'El servidor no confirmó la creación del perfil.',
        );
        return;
      }

      // El POST no devuelve las relaciones del GET /me.
      await _fetchProfile(
        emit,
        operationId: operationId,
        profileExpected: true,
        successMessage: api.message,
      );
    } catch (_) {
      if (!_isCurrent(emit, operationId)) return;

      _emitFailure(
        emit,
        message:
            'No se pudo confirmar la creación del perfil. '
            'Consulta nuevamente antes de repetir la operación.',
      );
    }
  }

  // *********************************************************
  // 4. ACTUALIZAR PERFIL
  // *********************************************************

  Future<void> _onUpdateSubmitted(
    CiudadanoCuentaUpdateSubmitted event,
    Emitter<CiudadanoCuentaState> emit,
  ) async {
    // Exigir una consulta exitosa antes de editar.
    if (state.isBusy ||
        !state.hasProfile ||
        state.status != CiudadanoCuentaStatus.ready) {
      return;
    }

    final operationId = ++_operationId;

    emit(
      state.copyWith(
        status: CiudadanoCuentaStatus.updating,
        clearMessages: true,
      ),
    );

    try {
      final resource = await ciudadanosUseCases.updateMiPerfilCiudadano.run(
        request: event.request,
      );

      if (!_isCurrent(emit, operationId)) return;

      if (resource is ErrorData<ApiResponse<UpdateCiudadanoPerfilDataModel>>) {
        _emitFailure(
          emit,
          message: resource.message,
          statusCode: resource.statusCode,
        );
        return;
      }

      if (resource is! Success<ApiResponse<UpdateCiudadanoPerfilDataModel>>) {
        _emitFailure(
          emit,
          message: 'No se recibió un resultado válido de la actualización.',
        );
        return;
      }

      final api = resource.data;

      if (!api.success || api.data == null) {
        _emitFailure(
          emit,
          message: 'El servidor no confirmó la actualización del perfil.',
        );
        return;
      }

      await _fetchProfile(
        emit,
        operationId: operationId,
        profileExpected: true,
        successMessage: api.message,
      );
    } catch (_) {
      if (!_isCurrent(emit, operationId)) return;

      _emitFailure(
        emit,
        message:
            'No se pudo confirmar la actualización. '
            'Consulta nuevamente tu perfil para verificar los cambios.',
      );
    }
  }

  // *********************************************************
  // 5. CONSULTA COMPARTIDA
  // *********************************************************

  Future<void> _fetchProfile(
    Emitter<CiudadanoCuentaState> emit, {
    required int operationId,
    bool profileExpected = false,
    String? successMessage,
  }) async {
    try {
      final resource = await ciudadanosUseCases.getMiPerfilCiudadano.run();

      if (!_isCurrent(emit, operationId)) return;

      if (resource is Success<ApiResponse<GetCiudadanoPerfilDataModel>>) {
        final api = resource.data;
        final perfil = api.data;

        if (!api.success || perfil == null) {
          _emitFailure(
            emit,
            message: 'El servidor no devolvió un perfil ciudadano válido.',
          );
          return;
        }

        emit(
          CiudadanoCuentaState(
            status: CiudadanoCuentaStatus.ready,
            perfil: perfil,
            successMessage: successMessage,
          ),
        );
        return;
      }

      if (resource is ErrorData<ApiResponse<GetCiudadanoPerfilDataModel>>) {
        // Aplicar esta condición únicamente si GET /me usa
        // 404 específicamente para indicar perfil inexistente.
        if (resource.statusCode == 404 && !profileExpected) {
          emit(
            const CiudadanoCuentaState(
              status: CiudadanoCuentaStatus.profileMissing,
            ),
          );
          return;
        }

        _emitFailure(
          emit,
          message: profileExpected
              ? 'El servidor confirmó el guardado, pero no se pudo '
                    'recargar el perfil. Vuelve a consultarlo.'
              : resource.message,
          statusCode: resource.statusCode,
        );
        return;
      }

      _emitFailure(
        emit,
        message: 'No se recibió un resultado válido al consultar el perfil.',
      );
    } catch (_) {
      if (!_isCurrent(emit, operationId)) return;

      _emitFailure(
        emit,
        message: profileExpected
            ? 'El servidor confirmó el guardado, pero no se pudo '
                  'recargar el perfil. Vuelve a consultarlo.'
            : 'No se pudo consultar tu perfil. Inténtalo nuevamente.',
      );
    }
  }

  // *********************************************************
  // 6. VALIDAR OPERACIÓN VIGENTE
  // *********************************************************

  bool _isCurrent(Emitter<CiudadanoCuentaState> emit, int operationId) {
    return !emit.isDone && operationId == _operationId;
  }

  // *********************************************************
  // 7. EMITIR ERROR
  // *********************************************************

  void _emitFailure(
    Emitter<CiudadanoCuentaState> emit, {
    required String message,
    int? statusCode,
  }) {
    emit(
      CiudadanoCuentaState(
        status: CiudadanoCuentaStatus.failure,
        perfil: state.perfil,
        errorMessage: message,
        statusCode: statusCode,
      ),
    );
  }
}
