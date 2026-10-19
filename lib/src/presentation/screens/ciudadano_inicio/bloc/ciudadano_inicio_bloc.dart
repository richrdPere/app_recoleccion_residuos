import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Uses cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'ciudadano_inicio_event.dart';
import 'ciudadano_inicio_state.dart';

class CiudadanoInicioBloc
    extends Bloc<CiudadanoInicioEvent, CiudadanoInicioState> {
  final DomiciliosUseCases domiciliosUseCases;

  int _loadId = 0;
  int _cronogramaId = 0;

  CiudadanoInicioBloc(this.domiciliosUseCases)
    : super(const CiudadanoInicioState()) {
    on<CiudadanoInicioRequested>(_onRequested);
    on<CiudadanoInicioDomicilioSelected>(_onDomicilioSelected);
    on<CiudadanoInicioCronogramaRequested>(_onCronogramaRequested);
    on<CiudadanoInicioReset>(_onReset);
  }

  // *********************************************************
  // 1. LIMPIAR ESTADO
  // *********************************************************

  void _onReset(
    CiudadanoInicioReset event,
    Emitter<CiudadanoInicioState> emit,
  ) {
    _loadId++;
    _cronogramaId++;

    emit(const CiudadanoInicioState());
  }

  // *********************************************************
  // 2. CARGAR DOMICILIOS E INICIO
  // *********************************************************

  Future<void> _onRequested(
    CiudadanoInicioRequested event,
    Emitter<CiudadanoInicioState> emit,
  ) async {
    final loadId = ++_loadId;

    // Invalidar el cronograma que pudiera estar pendiente.
    _cronogramaId++;

    final previousSelection = state.idDomicilioSeleccionado;

    emit(const CiudadanoInicioState(status: CiudadanoInicioStatus.loading));

    try {
      final resource = await domiciliosUseCases.getMisDomicilios.run(
        incluirInactivos: false,
      );

      if (!_isLoadCurrent(emit, loadId)) return;

      if (resource is ErrorData<ApiResponse<List<GetMisDomiciliosDataModel>>>) {
        emit(
          CiudadanoInicioState(
            status: CiudadanoInicioStatus.failure,
            errorMessage: resource.message,
            statusCode: resource.statusCode,
          ),
        );
        return;
      }

      if (resource is! Success<ApiResponse<List<GetMisDomiciliosDataModel>>>) {
        emit(
          const CiudadanoInicioState(
            status: CiudadanoInicioStatus.failure,
            errorMessage: 'No se recibió una respuesta válida de domicilios.',
          ),
        );
        return;
      }

      final api = resource.data;
      final data = api.data;

      if (!api.success || data == null) {
        emit(
          const CiudadanoInicioState(
            status: CiudadanoInicioStatus.failure,
            errorMessage:
                'El servidor no devolvió una lista válida de domicilios.',
          ),
        );
        return;
      }

      final domicilios = List<GetMisDomiciliosDataModel>.unmodifiable(data);

      // Lista vacía: es un resultado válido.
      if (domicilios.isEmpty) {
        emit(const CiudadanoInicioState(status: CiudadanoInicioStatus.ready));
        return;
      }

      final selected = _selectInitialAddress(domicilios, previousSelection);

      emit(
        CiudadanoInicioState(
          status: CiudadanoInicioStatus.ready,
          domicilios: domicilios,
          idDomicilioSeleccionado: selected.idDomicilio,
          cronogramaStatus: CiudadanoInicioCronogramaStatus.loading,
        ),
      );

      await _fetchCronograma(
        emit,
        idDomicilio: selected.idDomicilio,
        loadId: loadId,
      );
    } catch (_) {
      if (!_isLoadCurrent(emit, loadId)) return;

      emit(
        const CiudadanoInicioState(
          status: CiudadanoInicioStatus.failure,
          errorMessage:
              'No se pudo cargar el inicio ciudadano. '
              'Inténtalo nuevamente.',
        ),
      );
    }
  }

  // *********************************************************
  // 3. ELEGIR DOMICILIO INICIAL
  // *********************************************************

  GetMisDomiciliosDataModel _selectInitialAddress(
    List<GetMisDomiciliosDataModel> domicilios,
    int? previousSelection,
  ) {
    // Al actualizar, conservar la selección si todavía existe.
    if (previousSelection != null) {
      for (final domicilio in domicilios) {
        if (domicilio.idDomicilio == previousSelection) {
          return domicilio;
        }
      }
    }

    // Primera carga: preferir el principal.
    for (final domicilio in domicilios) {
      if (domicilio.esPrincipal) {
        return domicilio;
      }
    }

    return domicilios.first;
  }

  // *********************************************************
  // 4. CAMBIAR DOMICILIO CONSULTADO
  // *********************************************************

  Future<void> _onDomicilioSelected(
    CiudadanoInicioDomicilioSelected event,
    Emitter<CiudadanoInicioState> emit,
  ) async {
    if (state.status != CiudadanoInicioStatus.ready) return;

    final exists = state.domicilios.any(
      (domicilio) => domicilio.idDomicilio == event.idDomicilio,
    );

    if (!exists) return;

    if (state.idDomicilioSeleccionado == event.idDomicilio) {
      return;
    }

    emit(
      state.copyWith(
        idDomicilioSeleccionado: event.idDomicilio,
        cronogramaStatus: CiudadanoInicioCronogramaStatus.loading,
        clearCronograma: true,
        clearCronogramaError: true,
      ),
    );

    await _fetchCronograma(
      emit,
      idDomicilio: event.idDomicilio,
      loadId: _loadId,
    );
  }

  // *********************************************************
  // 5. REINTENTAR CRONOGRAMA
  // *********************************************************

  Future<void> _onCronogramaRequested(
    CiudadanoInicioCronogramaRequested event,
    Emitter<CiudadanoInicioState> emit,
  ) async {
    final idDomicilio = state.idDomicilioSeleccionado;

    if (state.status != CiudadanoInicioStatus.ready ||
        idDomicilio == null ||
        state.isCronogramaLoading) {
      return;
    }

    emit(
      state.copyWith(
        cronogramaStatus: CiudadanoInicioCronogramaStatus.loading,
        clearCronograma: true,
        clearCronogramaError: true,
      ),
    );

    await _fetchCronograma(emit, idDomicilio: idDomicilio, loadId: _loadId);
  }

  // *********************************************************
  // 6. CONSULTAR CRONOGRAMA
  // *********************************************************

  Future<void> _fetchCronograma(
    Emitter<CiudadanoInicioState> emit, {
    required int idDomicilio,
    required int loadId,
  }) async {
    final cronogramaId = ++_cronogramaId;

    bool isCurrent() {
      return !emit.isDone &&
          loadId == _loadId &&
          cronogramaId == _cronogramaId &&
          state.idDomicilioSeleccionado == idDomicilio;
    }

    try {
      final resource = await domiciliosUseCases.getDomicilioCronograma.run(
        idDomicilio: idDomicilio,
      );

      if (!isCurrent()) return;

      if (resource is ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>) {
        emit(
          state.copyWith(
            cronogramaStatus: CiudadanoInicioCronogramaStatus.failure,
            cronogramaErrorMessage: resource.message,
            cronogramaStatusCode: resource.statusCode,
            clearCronograma: true,
          ),
        );
        return;
      }

      if (resource is! Success<ApiResponse<GetDomicilioCronogramaDataModel>>) {
        _emitCronogramaFailure(
          emit,
          'No se recibió una respuesta válida del cronograma.',
        );
        return;
      }

      final api = resource.data;
      final cronograma = api.data;

      if (!api.success ||
          cronograma == null ||
          cronograma.domicilio.idDomicilio != idDomicilio) {
        _emitCronogramaFailure(
          emit,
          'El servidor no devolvió el cronograma '
          'del domicilio seleccionado.',
        );
        return;
      }

      emit(
        state.copyWith(
          cronogramaStatus: CiudadanoInicioCronogramaStatus.ready,
          cronograma: cronograma,
          clearCronogramaError: true,
        ),
      );
    } catch (_) {
      if (!isCurrent()) return;

      _emitCronogramaFailure(
        emit,
        'No se pudo consultar el cronograma. '
        'Inténtalo nuevamente.',
      );
    }
  }

  // *********************************************************
  // 7. VALIDAR CONSULTA DE INICIO
  // *********************************************************

  bool _isLoadCurrent(Emitter<CiudadanoInicioState> emit, int loadId) {
    return !emit.isDone && loadId == _loadId;
  }

  // *********************************************************
  // 8. ERROR DE CRONOGRAMA
  // *********************************************************

  void _emitCronogramaFailure(
    Emitter<CiudadanoInicioState> emit,
    String message,
  ) {
    emit(
      state.copyWith(
        cronogramaStatus: CiudadanoInicioCronogramaStatus.failure,
        cronogramaErrorMessage: message,
        clearCronograma: true,
      ),
    );
  }
}
