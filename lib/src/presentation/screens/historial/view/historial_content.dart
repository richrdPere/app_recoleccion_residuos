import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_state.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_bar_title_screen.dart';

class HistorialContent extends StatelessWidget {
  final RecorridoState state;
  final bool solicitudPendiente;
  final Future<void> Function() onRefresh;
  final Future<void> Function(int page) onPageChanged;

  const HistorialContent({
    super.key,
    required this.state,
    required this.solicitudPendiente,
    required this.onRefresh,
    required this.onPageChanged,
  });

  bool get _isBusy => solicitudPendiente || state.isLoadingHistorial;

  String? get _errorMessage {
    final response = state.historialResponse;

    if (response is ErrorData<ApiResponse<MisRecorridosDataModel>>) {
      return response.message;
    }

    return null;
  }

  // *********************************************************
  // 1. INTERFAZ
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final historial = state.historial;

    return Scaffold(
      appBar: AppBarTitleScreen(
        title: 'Mi historial',
        actions: [
          AppBarTitleAction(
            icon: Icons.refresh_rounded,
            tooltip: _isBusy
                ? 'Actualizando historial...'
                : 'Actualizar historial',
            color: _isBusy ? colors.primary : null,
            onPressed: () async {
              if (!_isBusy) await onRefresh();
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 360
                  ? 16.0
                  : 24.0;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isBusy) ...[
                            const LinearProgressIndicator(),
                            const SizedBox(height: 16),
                          ],
                          if (historial == null)
                            _buildWithoutData(context)
                          else ...[
                            if (_errorMessage != null) ...[
                              Text(
                                'No se pudo actualizar. Se mantiene '
                                'la última página consultada.',
                                style: TextStyle(color: colors.error),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _isBusy
                                      ? null
                                      : () async => await onRefresh(),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reintentar'),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            _buildSummary(context, historial),
                            const SizedBox(height: 20),
                            if (historial.items.isEmpty)
                              _buildEmpty(context)
                            else
                              ...historial.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildItem(context, item),
                                ),
                              ),
                            const SizedBox(height: 8),
                            _buildPagination(historial.pagination),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // *********************************************************
  // 2. CARGA INICIAL / ERROR
  // *********************************************************
  Widget _buildWithoutData(BuildContext context) {
    if (_isBusy || state.historialResponse == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('Consultando historial...')),
      );
    }

    final error = _errorMessage;

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async => await onRefresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return _buildEmpty(context);
  }

  // *********************************************************
  // 3. RESUMEN
  // *********************************************************
  Widget _buildSummary(BuildContext context, MisRecorridosDataModel historial) {
    final total = historial.pagination.totalItems;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recorridos en los que participaste',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('$total ${total == 1 ? 'recorrido' : 'recorridos'}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // *********************************************************
  // 4. HISTORIAL VACÍO
  // *********************************************************
  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay recorridos en esta página',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí podrás consultar tu participación '
            'en las operaciones de recolección.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // *********************************************************
  // 5. TARJETA DE RECORRIDO
  // *********************************************************
  Widget _buildItem(BuildContext context, MiRecorridoItemModel item) {
    final programacion = item.programacion;
    final ruta = programacion.ruta;
    final vehiculo = programacion.vehiculo;
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey('historial-recorrido-${item.idRecorrido}'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Icon(Icons.route_rounded, color: colors.primary),
        title: Text(
          'Recorrido #${item.idRecorrido}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ruta.nombre),
              const SizedBox(height: 4),
              Text(_fecha(item.fechaHoraInicio)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    label: Text(_label(item.estadoRecorrido)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(_label(item.miAsignacion.funcion)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
        children: [
          const Divider(),
          _dato('Programación', '#${item.idProgramacion}'),
          _dato('Ruta', '${ruta.codigo} · ${ruta.nombre}'),
          _dato('Vehículo', '${vehiculo.codigo} · ${vehiculo.placa}'),
          _dato('Turno', _label(programacion.turno)),
          _dato('Inicio', _fecha(item.fechaHoraInicio)),
          _dato('Finalización', _fecha(item.fechaHoraFinalizacion)),
          _dato('Duración registrada', _duracion(item.duracionSegundos)),
          _dato(
            'Distancia registrada',
            item.distanciaRecorridaMetros == null
                ? '—'
                : '${(item.distanciaRecorridaMetros! / 1000).toStringAsFixed(2)} km',
          ),
          if (item.observacionInicio?.trim().isNotEmpty == true)
            _observacion('Observación de inicio', item.observacionInicio!),
          if (item.observacionFinalizacion?.trim().isNotEmpty == true)
            _observacion(
              'Observación de finalización',
              item.observacionFinalizacion!,
            ),
          if (item.motivoCancelacion?.trim().isNotEmpty == true)
            _observacion('Motivo de cancelación', item.motivoCancelacion!),
        ],
      ),
    );
  }

  // *********************************************************
  // 6. PAGINACIÓN
  // *********************************************************
  Widget _buildPagination(RecorridosPaginationModel pagination) {
    if (pagination.totalPages <= 1 &&
        !pagination.hasPreviousPage &&
        !pagination.hasNextPage) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(
          'Página ${pagination.currentPage} '
          'de ${pagination.totalPages}',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isBusy || !pagination.hasPreviousPage
                    ? null
                    : () async {
                        await onPageChanged(pagination.currentPage - 1);
                      },
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Anterior'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isBusy || !pagination.hasNextPage
                    ? null
                    : () async {
                        await onPageChanged(pagination.currentPage + 1);
                      },
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(titulo)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _observacion(String titulo, String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(texto),
        ],
      ),
    );
  }

  String _label(String value) => value.replaceAll('_', ' ');

  String _fecha(String? value) {
    if (value == null || value.isEmpty) return '—';

    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;

    String dos(int n) => n.toString().padLeft(2, '0');

    return '${dos(date.day)}/${dos(date.month)}/${date.year} '
        '${dos(date.hour)}:${dos(date.minute)}';
  }

  String _duracion(int? segundos) {
    if (segundos == null || segundos < 0) return '—';

    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;

    if (horas > 0) return '${horas}h ${minutos}min';
    if (segundos < 60) return '${segundos}s';

    return '${minutos}min';
  }
}
