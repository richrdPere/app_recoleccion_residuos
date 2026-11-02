import 'package:flutter/material.dart';

import '../cubit/notificaciones_state.dart';

import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_search_field.dart';

class NotificacionesContent extends StatelessWidget {
  final NotificacionesState state;

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;

  final ValueChanged<bool> onArchived;
  final ValueChanged<bool> onUnread;

  final ValueChanged<int> onOpen;

  final Future<bool> Function(int) onRead;
  final Future<bool> Function(int) onArchive;

  final VoidCallback onReadAll;

  const NotificacionesContent({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearch,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onArchived,
    required this.onUnread,
    required this.onOpen,
    required this.onRead,
    required this.onArchive,
    required this.onReadAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            tooltip: 'Marcar todas como leídas',
            onPressed: state.mutating || state.unread == 0 ? null : onReadAll,
            icon: const Icon(Icons.done_all),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: state.loading ? null : onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.userId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: AppSearchField(
                userId: state.userId!,
                historyScope: 'notificaciones.bandeja',
                query: state.search,
                hintText: 'Buscar notificaciones',
                emptyTitle: 'Busca una notificación',
                emptyDescription: 'Escribe parte del título o del mensaje.',
                resultsSubtitle: 'Filtrar mis notificaciones',
                allowEmptyQuery: true,
                onSearch: onSearch,
              ),
            ),

          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          //   child: TextField(
          //     controller: searchController,
          //     onChanged: onSearch,
          //     decoration: InputDecoration(
          //       hintText: 'Buscar por título o mensaje',
          //       prefixIcon: const Icon(Icons.search),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //       suffixIcon: IconButton(
          //         tooltip: 'Limpiar búsqueda',
          //         onPressed: () {
          //           searchController.clear();
          //           onSearch('');
          //         },
          //         icon: const Icon(Icons.close),
          //       ),
          //     ),
          //   ),
          // ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Bandeja'),
                  selected: !state.archived,
                  onSelected: (_) => onArchived(false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Archivadas'),
                  selected: state.archived,
                  onSelected: (_) => onArchived(true),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Solo no leídas'),
                  selected: state.onlyUnread,
                  onSelected: onUnread,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${state.total} resultados',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  '${state.unread} sin leer',
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
          ),
          if (state.loading || state.mutating) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: state.items.isEmpty ? 1 : state.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (state.items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 72,
                        horizontal: 24,
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.notifications_none, size: 56),
                          const SizedBox(height: 16),
                          Text(
                            state.loading
                                ? 'Cargando notificaciones…'
                                : state.error ??
                                      'No hay notificaciones '
                                          'para estos filtros.',
                            textAlign: TextAlign.center,
                          ),
                          if (state.error != null)
                            TextButton(
                              onPressed: onRefresh,
                              child: const Text('Reintentar'),
                            ),
                        ],
                      ),
                    );
                  }

                  if (index == state.items.length) {
                    if (!state.hasMore) {
                      return const SizedBox(height: 16);
                    }

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: OutlinedButton(
                          onPressed: state.loadingMore || state.loading
                              ? null
                              : onLoadMore,
                          child: Text(
                            state.loadingMore ? 'Cargando…' : 'Cargar más',
                          ),
                        ),
                      ),
                    );
                  }

                  final item = state.items[index];
                  final note = item.notificacion;

                  return Card(
                    elevation: 0,
                    color: item.leida
                        ? colors.surfaceContainerLow
                        : colors.primaryContainer,
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                      leading: Icon(
                        item.leida
                            ? Icons.notifications_outlined
                            : Icons.mark_email_unread_outlined,
                      ),
                      title: Text(
                        note.titulo,
                        style: TextStyle(
                          fontWeight: item.leida
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            note.mensaje,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notificationDate(item.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () => onOpen(item.idNotificacionUsuario),
                      trailing: item.leida && item.archivada
                          ? null
                          : PopupMenuButton<String>(
                              enabled: !state.mutating,
                              onSelected: (action) async {
                                if (action == 'read') {
                                  await onRead(item.idNotificacionUsuario);
                                }

                                if (action == 'archive') {
                                  await onArchive(item.idNotificacionUsuario);
                                }
                              },
                              itemBuilder: (_) => [
                                if (!item.leida)
                                  const PopupMenuItem(
                                    value: 'read',
                                    child: Text('Marcar como leída'),
                                  ),
                                if (!item.archivada)
                                  const PopupMenuItem(
                                    value: 'archive',
                                    child: Text('Archivar'),
                                  ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String notificationDate(DateTime date) {
  final local = date.toLocal();

  String two(int value) => value.toString().padLeft(2, '0');

  return '${two(local.day)}/${two(local.month)}/${local.year}'
      ' · ${two(local.hour)}:${two(local.minute)}';
}
