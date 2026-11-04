import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

import 'ciudadano_preferencias_event.dart';
import 'ciudadano_preferencias_state.dart';

class CiudadanoPreferenciasBloc
    extends Bloc<CiudadanoPreferenciasEvent, CiudadanoPreferenciasState> {
  final PrefNotificationUseCases useCases;
  final int idCiudadano;

  int _operationId = 0;

  CiudadanoPreferenciasBloc({required this.useCases, required this.idCiudadano})
    : super(const CiudadanoPreferenciasState()) {
    on<CiudadanoPreferenciasRequested>(_onRequested);
    on<CiudadanoPreferenciasSubmitted>(_onSubmitted);
  }

  bool _isCurrent(Emitter<CiudadanoPreferenciasState> emit, int operation) {
    return !isClosed && !emit.isDone && operation == _operationId;
  }

  Future<void> _onRequested(
    CiudadanoPreferenciasRequested event,
    Emitter<CiudadanoPreferenciasState> emit,
  ) async {
    if (state.isBusy) return;

    final operation = ++_operationId;
    final revision = state.revision;

    emit(
      CiudadanoPreferenciasState(
        status: CiudadanoPreferenciasStatus.loading,
        revision: revision,
      ),
    );

    try {
      final result = await useCases.getCiudadanoPreferencias.run();

      if (!_isCurrent(emit, operation)) return;

      if (result is ErrorData<ApiResponse<GetCiudadanoPreferenciasDataModel>>) {
        emit(
          CiudadanoPreferenciasState(
            status: CiudadanoPreferenciasStatus.failure,
            errorMessage: result.message,
            statusCode: result.statusCode,
            revision: revision,
          ),
        );
        return;
      }

      if (result is! Success<ApiResponse<GetCiudadanoPreferenciasDataModel>>) {
        throw const FormatException();
      }

      final api = result.data;
      final data = api.data;

      if (!api.success || data == null || data.idCiudadano != idCiudadano) {
        throw const FormatException();
      }

      emit(
        CiudadanoPreferenciasState(
          status: CiudadanoPreferenciasStatus.ready,
          preferencias: data,
          revision: revision + 1,
        ),
      );
    } catch (_) {
      if (!_isCurrent(emit, operation)) return;

      emit(
        CiudadanoPreferenciasState(
          status: CiudadanoPreferenciasStatus.failure,
          errorMessage: 'No se pudieron consultar tus preferencias.',
          revision: revision,
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    CiudadanoPreferenciasSubmitted event,
    Emitter<CiudadanoPreferenciasState> emit,
  ) async {
    if (state.isBusy || state.preferencias == null) {
      return;
    }

    final previous = state.preferencias!;
    final revision = state.revision;
    final operation = ++_operationId;

    emit(
      CiudadanoPreferenciasState(
        status: CiudadanoPreferenciasStatus.saving,
        preferencias: previous,
        revision: revision,
      ),
    );

    try {
      final result = await useCases.updateCiudadanoPreferencias.run(
        request: event.request,
      );

      if (!_isCurrent(emit, operation)) return;

      if (result
          is ErrorData<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>) {
        emit(
          CiudadanoPreferenciasState(
            status: CiudadanoPreferenciasStatus.failure,
            preferencias: previous,
            errorMessage: result.message,
            statusCode: result.statusCode,
            revision: revision,
          ),
        );
        return;
      }

      if (result
          is! Success<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>) {
        throw const FormatException();
      }

      final api = result.data;
      final data = api.data;

      if (!api.success || data == null || data.idCiudadano != idCiudadano) {
        throw const FormatException();
      }

      final expected = event.request.toJson();
      final actual = data.toJson();

      if (expected.entries.any((entry) => actual[entry.key] != entry.value)) {
        throw const FormatException();
      }

      emit(
        CiudadanoPreferenciasState(
          status: CiudadanoPreferenciasStatus.saved,
          preferencias: data,
          revision: revision + 1,
        ),
      );
    } catch (_) {
      if (!_isCurrent(emit, operation)) return;

      emit(
        CiudadanoPreferenciasState(
          status: CiudadanoPreferenciasStatus.failure,
          preferencias: previous,
          errorMessage:
              'No se pudo confirmar el guardado. '
              'Vuelve a consultar tus preferencias '
              'antes de repetirlo.',
          revision: revision,
        ),
      );
    }
  }
}
