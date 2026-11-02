import 'package:flutter/material.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_search_page.dart';

class AppSearchField extends StatefulWidget {
  final String userId;
  final String historyScope;

  final String query;
  final String hintText;

  final String emptyTitle;
  final String emptyDescription;
  final String resultsSubtitle;

  final bool allowEmptyQuery;
  final bool enabled;

  final ValueChanged<String> onSearch;

  const AppSearchField({
    super.key,
    required this.userId,
    required this.historyScope,
    required this.onSearch,
    this.query = '',
    this.hintText = 'Buscar...',
    this.emptyTitle = '¿Qué deseas buscar?',
    this.emptyDescription = 'Escribe un término y pulsa buscar.',
    this.resultsSubtitle = 'Ver resultados',
    this.allowEmptyQuery = true,
    this.enabled = true,
  }) : assert(userId != ''),
       assert(historyScope != '');

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  bool _opening = false;

  Future<void> _openSearch() async {
    if (!widget.enabled || _opening) return;

    final userId = widget.userId;
    final scope = widget.historyScope;
    final originRoute = ModalRoute.of(context);

    setState(() {
      _opening = true;
    });

    try {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => AppSearchPage(
            key: ValueKey('$userId:$scope'),
            userId: userId,
            historyScope: scope,
            initialQuery: widget.query,
            hintText: widget.hintText,
            emptyTitle: widget.emptyTitle,
            emptyDescription: widget.emptyDescription,
            resultsSubtitle: widget.resultsSubtitle,
            allowEmptyQuery: widget.allowEmptyQuery,
          ),
        ),
      );

      if (!mounted ||
          widget.userId != userId ||
          widget.historyScope != scope ||
          !widget.enabled) {
        return;
      }

      // Evitar aplicar un resultado si otra pantalla
      // pasó a ocupar el lugar de la pantalla original.
      if (originRoute != null && !originRoute.isCurrent) {
        return;
      }

      // null significa cancelar: conservar la consulta.
      if (result == null) return;

      final query = result.trim();

      if (query.isEmpty && !widget.allowEmptyQuery) {
        return;
      }

      widget.onSearch(query);
    } finally {
      if (mounted) {
        setState(() {
          _opening = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final query = widget.query.trim();

    final habilitado = widget.enabled && !_opening;

    return Material(
      color: colors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.50)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: habilitado ? _openSearch : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: habilitado ? colors.primary : colors.onSurfaceVariant,
                size: 25,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    query.isEmpty ? widget.hintText : query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: query.isEmpty
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      fontSize: 14,
                      fontWeight: query.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),

              if (_opening)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                )
              else if (query.isNotEmpty && widget.allowEmptyQuery)
                IconButton(
                  tooltip: 'Quitar búsqueda',
                  onPressed: widget.enabled ? () => widget.onSearch('') : null,
                  icon: const Icon(Icons.close_rounded, size: 21),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.history_rounded,
                    size: 21,
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
