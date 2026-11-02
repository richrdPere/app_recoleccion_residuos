import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class HistorialFiltrosSheet extends StatefulWidget {
  final HistorialFiltros filtros;

  const HistorialFiltrosSheet({super.key, required this.filtros});

  @override
  State<HistorialFiltrosSheet> createState() => _HistorialFiltrosSheetState();
}

class _HistorialFiltrosSheetState extends State<HistorialFiltrosSheet> {
  String? _estado;
  DateTime? _desde;
  DateTime? _hasta;

  String? _error;

  static const _estados = <String, String>{
    'EN_CURSO': 'En curso',
    'PAUSADO': 'Pausado',
    'FINALIZADO': 'Finalizado',
    'CANCELADO': 'Cancelado',
  };

  @override
  void initState() {
    super.initState();

    _estado = widget.filtros.estado;
    _desde = widget.filtros.fechaDesde;
    _hasta = widget.filtros.fechaHasta;
  }

  Future<void> _seleccionarFecha({required bool desde}) async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate:
          (desde ? _desde : _hasta) ?? DateUtils.dateOnly(DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      helpText: desde
          ? 'Fecha de inicio del periodo'
          : 'Fecha final del periodo',
    );

    if (!mounted || seleccionada == null) return;

    setState(() {
      if (desde) {
        _desde = DateUtils.dateOnly(seleccionada);
      } else {
        _hasta = DateUtils.dateOnly(seleccionada);
      }

      _error = null;
    });
  }

  void _limpiar() {
    setState(() {
      _estado = null;
      _desde = null;
      _hasta = null;
      _error = null;
    });
  }

  void _aplicar() {
    if (_desde != null && _hasta != null && _desde!.isAfter(_hasta!)) {
      setState(() {
        _error = 'La fecha desde no puede ser posterior a la fecha hasta.';
      });

      return;
    }

    Navigator.of(context).pop(
      HistorialFiltros(
        // Los filtros no eliminan la búsqueda aplicada.
        search: widget.filtros.search,
        estado: _estado,
        fechaDesde: _desde,
        fechaHasta: _hasta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtrar historial',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: _limpiar, child: const Text('Limpiar')),
              ],
            ),

            const SizedBox(height: 20),

            Text('Estado del recorrido', style: theme.textTheme.titleSmall),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _estado == null,
                  onSelected: (_) {
                    setState(() => _estado = null);
                  },
                ),
                for (final opcion in _estados.entries)
                  ChoiceChip(
                    label: Text(opcion.value),
                    selected: _estado == opcion.key,
                    onSelected: (_) {
                      setState(() => _estado = opcion.key);
                    },
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Fecha de inicio del recorrido (UTC)',
              style: theme.textTheme.titleSmall,
            ),

            const SizedBox(height: 10),

            _campoFecha(
              titulo: 'Desde',
              fecha: _desde,
              onSeleccionar: () => _seleccionarFecha(desde: true),
              onLimpiar: () {
                setState(() {
                  _desde = null;
                  _error = null;
                });
              },
            ),

            const SizedBox(height: 10),

            _campoFecha(
              titulo: 'Hasta',
              fecha: _hasta,
              onSeleccionar: () => _seleccionarFecha(desde: false),
              onLimpiar: () {
                setState(() {
                  _hasta = null;
                  _error = null;
                });
              },
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: colors.error)),
            ],

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _aplicar,
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoFecha({
    required String titulo,
    required DateTime? fecha,
    required VoidCallback onSeleccionar,
    required VoidCallback onLimpiar,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onSeleccionar,
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(titulo),
        subtitle: Text(
          fecha == null ? 'Sin límite' : HistorialFiltros.fechaApi(fecha),
        ),
        trailing: fecha == null
            ? const Icon(Icons.chevron_right_rounded)
            : IconButton(
                tooltip: 'Quitar fecha',
                onPressed: onLimpiar,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}
