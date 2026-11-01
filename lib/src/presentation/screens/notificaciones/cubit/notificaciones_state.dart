import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class NotificacionesState {
  final String? userId;

  final List<MiNotificacionItemModel> items;

  final int page;
  final int total;
  final int unread;

  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final bool mutating;

  final bool archived;
  final bool onlyUnread;

  final String search;
  final String? error;

  const NotificacionesState({
    this.userId,
    this.items = const [],
    this.page = 0,
    this.total = 0,
    this.unread = 0,
    this.hasMore = false,
    this.loading = false,
    this.loadingMore = false,
    this.mutating = false,
    this.archived = false,
    this.onlyUnread = false,
    this.search = '',
    this.error,
  });

  NotificacionesState copyWith({
    List<MiNotificacionItemModel>? items,
    int? page,
    int? total,
    int? unread,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    bool? mutating,
    bool? archived,
    bool? onlyUnread,
    String? search,
    String? error,
    bool clearError = false,
  }) {
    return NotificacionesState(
      userId: userId,
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      unread: unread ?? this.unread,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      mutating: mutating ?? this.mutating,
      archived: archived ?? this.archived,
      onlyUnread: onlyUnread ?? this.onlyUnread,
      search: search ?? this.search,
      error: clearError ? null : error ?? this.error,
    );
  }
}
