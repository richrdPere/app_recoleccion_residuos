import 'package:flutter/material.dart';

// Service
import 'package:app_recoleccion_residuos/src/data/datasources/local/local.dart';

class AppSearchPage extends StatefulWidget {
  /// Identificador del usuario autenticado.
  final String userId;

  /// Identificador estable del módulo:
  /// zonas, patrullajes, incidencias, etc.
  final String historyScope;

  final String initialQuery;
  final String hintText;
  final String emptyTitle;
  final String emptyDescription;
  final String resultsSubtitle;
  final int historyLimit;
  final bool allowEmptyQuery;

  const AppSearchPage({
    super.key,
    required this.userId,
    required this.historyScope,
    this.initialQuery = '',
    this.hintText = 'Buscar...',
    this.emptyTitle = '¿Qué deseas buscar?',
    this.emptyDescription = 'Escribe un término y pulsa buscar.',
    this.resultsSubtitle = 'Ver resultados',
    this.historyLimit = 15,
    this.allowEmptyQuery = true,
  }) : assert(userId != ''),
       assert(historyScope != ''),
       assert(historyLimit > 0);

  @override
  State<AppSearchPage> createState() => _AppSearchPageState();
}

class _AppSearchPageState extends State<AppSearchPage> {
  final SearchHistoryService _historyService = SearchHistoryService();
  final FocusNode _focusNode = FocusNode();

  late final TextEditingController _controller;

  List<String> _history = [];

  bool _isLoadingHistory = true;
  bool _isSaving = false;
  String? _historyError;

  bool get _isBusy => _isLoadingHistory || _isSaving;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialQuery);

    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );

    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ======================================================
  // HISTORIAL
  // ======================================================

  Future<void> _loadHistory() async {
    try {
      final items = await _historyService.read(
        userId: widget.userId,
        scope: widget.historyScope,
      );

      if (!mounted) return;

      final seen = <String>{};

      setState(() {
        _history = items
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty && seen.add(item.toLowerCase()))
            .take(widget.historyLimit)
            .toList();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _historyError = 'No se pudo cargar el historial de búsquedas.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _updateHistory(List<String> items) async {
    if (_isBusy) return;

    setState(() => _isSaving = true);

    try {
      await _historyService.write(
        userId: widget.userId,
        scope: widget.historyScope,
        items: items,
      );

      if (!mounted) return;

      setState(() {
        _history = items;
        _historyError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _historyError = 'No se pudo actualizar el historial.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _removeHistoryItem(String value) async {
    await _updateHistory(
      _history
          .where((item) => item.toLowerCase() != value.toLowerCase())
          .toList(),
    );
  }

  Future<void> _clearHistory() async {
    await _updateHistory([]);
  }

  // ======================================================
  // BUSCAR
  // ======================================================
  Future<void> _submit([String? selectedQuery]) async {
    if (_isBusy) return;

    final query = (selectedQuery ?? _controller.text).trim();
    if (query.isEmpty && !widget.allowEmptyQuery) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe una dirección o lugar para buscar.'),
        ),
      );

      _focusNode.requestFocus();
      return;
    }

    final route = ModalRoute.of(context);

    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    try {
      if (query.isNotEmpty) {
        // Si falló la lectura, no sobrescribimos un historial
        // existente con una lista incompleta.
        if (_historyError == null) {
          final updated = [
            query,
            ..._history.where(
              (item) => item.toLowerCase() != query.toLowerCase(),
            ),
          ].take(widget.historyLimit).toList();

          await _historyService.write(
            userId: widget.userId,
            scope: widget.historyScope,
            items: updated,
          );
        }
      }
    } catch (_) {
      // Un fallo al guardar el historial no impide buscar.
      debugPrint('No se pudo guardar la búsqueda reciente.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    // Evita cerrar otra pantalla si el usuario volvió atrás
    // mientras se guardaba el historial.
    if (!mounted || route?.isCurrent != true) return;

    Navigator.of(context).pop<String>(query);
  }

  void _clearText() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  // ======================================================
  // BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        toolbarHeight: 62,
        title: Row(
          children: [
            // ==================================================
            // BUSCADOR CON LUPA
            // ==================================================
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                enabled: !_isSaving,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) {
                  if (!_isBusy) {
                    _submit();
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary),
                  ),

                  // Lupa integrada: también permite enviar la búsqueda.
                  prefixIcon: _isSaving
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          tooltip: 'Buscar',
                          onPressed: _isBusy ? null : () => _submit(),
                          icon: const Icon(Icons.search_rounded),
                        ),

                  // Borrar el texto sin cerrar el buscador.
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        tooltip: 'Borrar texto',
                        onPressed: _isSaving ? null : _clearText,
                        icon: const Icon(Icons.close_rounded),
                      );
                    },
                  ),
                ),
              ),
            ),

            // const SizedBox(width: 16),

            // ==================================================
            // CANCELAR
            // ==================================================
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();

                // Devuelve null: conserva los filtros actuales.
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            final query = value.text.trim();

            final recentItems = _history.where((item) {
              return query.isEmpty ||
                  item.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_isLoadingHistory) const LinearProgressIndicator(),

                if (_historyError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _historyError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),

                if (query.isNotEmpty)
                  ListTile(
                    leading: Icon(Icons.search_rounded, color: colors.primary),
                    title: Text(
                      'Buscar “$query”',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(widget.resultsSubtitle),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: _isBusy ? null : () => _submit(),
                  ),

                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Búsquedas recientes',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isBusy ? null : _clearHistory,
                        child: const Text('Borrar todo'),
                      ),
                    ],
                  ),

                  if (recentItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No hay búsquedas recientes que coincidan.'),
                    ),

                  ...recentItems.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.history_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                      title: Text(
                        item,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: _isBusy ? null : () => _submit(item),
                      trailing: IconButton(
                        tooltip: 'Eliminar del historial',
                        onPressed: _isBusy
                            ? null
                            : () => _removeHistoryItem(item),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
                ],

                if (!_isLoadingHistory &&
                    query.isEmpty &&
                    _history.isEmpty) ...[
                  const SizedBox(height: 32),
                  Icon(
                    Icons.search_rounded,
                    size: 48,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.emptyTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.emptyDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],

                if (widget.allowEmptyQuery &&
                    widget.initialQuery.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: _isBusy ? null : () => _submit(''),
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Quitar búsqueda aplicada'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
