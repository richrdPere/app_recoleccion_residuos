import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

import 'notificaciones_state.dart';

class NotificacionesCubit extends Cubit<NotificacionesState> {
  final NotificacionesUseCases useCases;

  int _generation = 0;
  int _listRequest = 0;
  int _countRequest = 0;

  NotificacionesCubit(this.useCases) : super(const NotificacionesState());

  bool _current(int generation) {
    return !isClosed && generation == _generation;
  }

  // Limpiar inmediatamente al cerrar sesión o cambiar de cuenta.
  void bindSession(String? userId) {
    if (isClosed || state.userId == userId) return;

    _generation++;
    _listRequest++;
    _countRequest++;

    emit(NotificacionesState(userId: userId));
  }

  Future<void> refresh() {
    return _load(append: false);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loading || state.loadingMore) {
      return;
    }

    await _load(append: true);
  }

  Future<void> setFilters({
    bool? archived,
    bool? onlyUnread,
    String? search,
  }) async {
    if (isClosed || state.userId == null) return;

    final nextArchived = archived ?? state.archived;
    final nextUnread = onlyUnread ?? state.onlyUnread;
    final nextSearch = search?.trim() ?? state.search;

    if (state.archived == nextArchived &&
        state.onlyUnread == nextUnread &&
        state.search == nextSearch) {
      return;
    }

    _listRequest++;

    emit(
      state.copyWith(
        archived: nextArchived,
        onlyUnread: nextUnread,
        search: nextSearch,
        items: const [],
        page: 0,
        total: 0,
        hasMore: false,
        loading: false,
        loadingMore: false,
        clearError: true,
      ),
    );

    await refresh();
  }

  Future<void> _load({required bool append}) async {
    if (isClosed || state.userId == null) return;

    final generation = _generation;
    final request = ++_listRequest;

    final query = GetMisNotificacionesRequest(
      page: append ? state.page + 1 : 1,
      limit: 20,
      archivada: state.archived,
      leida: state.onlyUnread ? false : null,
      search: state.search,
    );

    emit(
      state.copyWith(loading: !append, loadingMore: append, clearError: true),
    );

    try {
      final result = await useCases.getMisNotificaciones.run(query: query);

      if (!_current(generation) || request != _listRequest) {
        return;
      }

      if (result is! Success<ApiResponse<GetMisNotificacionesDataModel>>) {
        throw StateError(_error(result));
      }

      final data = result.data.data;

      if (data == null) {
        throw StateError('El servidor no devolvió los datos de la bandeja.');
      }

      final merged = <int, MiNotificacionItemModel>{
        if (append)
          for (final item in state.items) item.idNotificacionUsuario: item,
        for (final item in data.items) item.idNotificacionUsuario: item,
      };

      emit(
        state.copyWith(
          items: List<MiNotificacionItemModel>.unmodifiable(merged.values),
          page: data.page,
          total: data.total,
          hasMore: data.hasNextPage,
          loading: false,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      if (!_current(generation) || request != _listRequest) {
        return;
      }

      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          error: _error(error),
        ),
      );
    }
  }

  Future<void> refreshCount() async {
    if (isClosed || state.userId == null) return;

    final generation = _generation;
    final request = ++_countRequest;

    try {
      final result = await useCases.getTotalNoLeidas.run();

      if (!_current(generation) || request != _countRequest) {
        return;
      }

      if (result is Success<ApiResponse<GetTotalNoLeidasDataModel>>) {
        final data = result.data.data;

        if (data != null) {
          emit(state.copyWith(unread: data.totalNoLeidas));
        }
      }
    } catch (_) {
      // Un fallo del contador no reemplaza la bandeja
      // ni simula un contador de cero.
    }
  }

  Future<bool> markRead(int id) {
    return _mutate(() async {
      final result = await useCases.marcarNotificacionLeida.run(id: id);

      if (result is! Success<ApiResponse<MarcarNotificacionLeidaDataModel>>) {
        throw StateError(_error(result));
      }
    });
  }

  Future<bool> archive(int id) {
    return _mutate(() async {
      final result = await useCases.archivarNotificacion.run(id: id);

      if (result is! Success<ApiResponse<ArchivarNotificacionDataModel>>) {
        throw StateError(_error(result));
      }
    });
  }

  Future<bool> markAllRead() {
    return _mutate(() async {
      final result = await useCases.marcarTodasNotificacionesLeidas.run();

      if (result
          is! Success<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>) {
        throw StateError(_error(result));
      }
    });
  }

  Future<bool> _mutate(Future<void> Function() operation) async {
    if (isClosed || state.userId == null || state.mutating) {
      return false;
    }

    final generation = _generation;

    emit(state.copyWith(mutating: true, clearError: true));

    try {
      await operation();

      if (!_current(generation)) return false;

      await Future.wait([refresh(), refreshCount()]);

      return _current(generation);
    } catch (error) {
      if (_current(generation)) {
        emit(state.copyWith(error: _error(error)));
      }

      return false;
    } finally {
      if (_current(generation)) {
        emit(state.copyWith(mutating: false));
      }
    }
  }

  String _error(Object result) {
    if (result is ErrorData) {
      return result.message;
    }

    if (result is StateError) {
      return result.message.toString();
    }

    return 'No se pudo completar la operación. Inténtalo nuevamente.';
  }
}
