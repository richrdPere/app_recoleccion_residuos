import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class IncidenciasContent extends StatelessWidget {
  final List<IncidenciaListadoModel> incidencias;
  final IncidenciasPaginationModel? pagination;

  final bool isLoading;
  final String? errorMessage;

  final TextEditingController searchController;

  final String tipo;
  final String prioridad;
  final String estado;

  final bool hayFiltros;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTipoChanged;
  final ValueChanged<String> onPrioridadChanged;
  final ValueChanged<String> onEstadoChanged;

  final VoidCallback onLimpiarFiltros;
  final Future<void> Function() onRefresh;
  final VoidCallback onReintentar;

  final ValueChanged<int> onCambiarPagina;
  final ValueChanged<int>? onVerIncidencia;

  const IncidenciasContent({
    super.key,
    required this.incidencias,
    required this.pagination,
    required this.isLoading,
    required this.errorMessage,
    required this.searchController,
    required this.tipo,
    required this.prioridad,
    required this.estado,
    required this.hayFiltros,
    required this.onSearchChanged,
    required this.onTipoChanged,
    required this.onPrioridadChanged,
    required this.onEstadoChanged,
    required this.onLimpiarFiltros,
    required this.onRefresh,
    required this.onReintentar,
    required this.onCambiarPagina,
    this.onVerIncidencia,
  });

  // *********************************************************
  // OPCIONES
  // *********************************************************

  static const _tipos = <String, String>{
    '': 'Todos los tipos',
    'VIA_BLOQUEADA': 'Vía bloqueada',
    'AVERIA_VEHICULO': 'Avería del vehículo',
    'ACCIDENTE': 'Accidente',
    'RECOLECCION_NO_REALIZADA': 'Recolección no realizada',
    'ACUMULACION_RESIDUOS': 'Acumulación de residuos',
    'PUNTO_INACCESIBLE': 'Punto inaccesible',
    'OTRO': 'Otro',
  };

  static const _prioridades = <String, String>{
    '': 'Todas las prioridades',
    'BAJA': 'Baja',
    'MEDIA': 'Media',
    'ALTA': 'Alta',
    'CRITICA': 'Crítica',
  };

  static const _estados = <String, String>{
    '': 'Todos los estados',
    'REPORTADA': 'Reportada',
    'EN_REVISION': 'En revisión',
    'EN_ATENCION': 'En atención',
    'RESUELTA': 'Resuelta',
    'RECHAZADA': 'Rechazada',
    'CANCELADA': 'Cancelada',
  };

  // *********************************************************
  // BUILD
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paginacion = pagination;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text(
            'Seguimiento de reportes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Consulta el estado de atención de las incidencias '
            'del servicio de recolección.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          // BÚSQUEDA
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onReintentar(),
            decoration: InputDecoration(
              hintText: 'Buscar por título o descripción',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // FILTROS
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _selector(
                    label: 'Tipo de incidencia',
                    value: tipo,
                    opciones: _tipos,
                    onChanged: onTipoChanged,
                  ),
                  const SizedBox(height: 12),
                  _selector(
                    label: 'Prioridad',
                    value: prioridad,
                    opciones: _prioridades,
                    onChanged: onPrioridadChanged,
                  ),
                  const SizedBox(height: 12),
                  _selector(
                    label: 'Estado de atención',
                    value: estado,
                    opciones: _estados,
                    onChanged: onEstadoChanged,
                  ),
                  if (hayFiltros) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onLimpiarFiltros,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Limpiar filtros'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // RESUMEN DEL LISTADO
          Row(
            children: [
              Expanded(
                child: Text(
                  'Incidencias',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (paginacion != null)
                Text(
                  '${paginacion.total} '
                  '${paginacion.total == 1 ? 'reporte' : 'reportes'}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // CARGA INICIAL
          if (isLoading && incidencias.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          // ERROR
          else if (errorMessage != null)
            _mensaje(
              context,
              icon: Icons.error_outline_rounded,
              titulo: 'No se pudieron cargar las incidencias',
              descripcion: errorMessage!,
              textoBoton: 'Reintentar',
              onPressed: onReintentar,
            )
          // VACÍO
          else if (incidencias.isEmpty)
            _mensaje(
              context,
              icon: Icons.fact_check_outlined,
              titulo: hayFiltros
                  ? 'Sin coincidencias'
                  : 'Sin incidencias disponibles',
              descripcion: hayFiltros
                  ? 'Prueba con otros filtros o modifica la búsqueda.'
                  : 'Los reportes disponibles para tu usuario '
                        'aparecerán aquí.',
              textoBoton: hayFiltros ? 'Limpiar filtros' : 'Actualizar',
              onPressed: hayFiltros ? onLimpiarFiltros : onReintentar,
            )
          // RESULTADOS
          else ...[
            for (final incidencia in incidencias)
              Padding(
                key: ValueKey(incidencia.idIncidencia),
                padding: const EdgeInsets.only(bottom: 12),
                child: _IncidenciaCard(
                  incidencia: incidencia,
                  onTap: isLoading || onVerIncidencia == null
                      ? null
                      : () {
                          onVerIncidencia!(incidencia.idIncidencia);
                        },
                ),
              ),

            // PAGINACIÓN
            if (paginacion != null && paginacion.total > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Página ${paginacion.page} '
                'de ${paginacion.totalPages}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading || paginacion.page <= 1
                          ? null
                          : () {
                              onCambiarPagina(paginacion.page - 1);
                            },
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          isLoading || paginacion.page >= paginacion.totalPages
                          ? null
                          : () {
                              onCambiarPagina(paginacion.page + 1);
                            },
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('Siguiente'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  // *********************************************************
  // SELECTOR
  // *********************************************************

  Widget _selector({
    required String label,
    required String value,
    required Map<String, String> opciones,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label:$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: opciones.entries
          .map(
            (opcion) => DropdownMenuItem<String>(
              value: opcion.key,
              child: Text(opcion.value, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }

  // *********************************************************
  // ESTADO VACÍO / ERROR
  // *********************************************************

  Widget _mensaje(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String descripcion,
    required String textoBoton,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 52, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onPressed, child: Text(textoBoton)),
        ],
      ),
    );
  }
}

// *********************************************************
// TARJETA DE INCIDENCIA
// *********************************************************

class _IncidenciaCard extends StatelessWidget {
  final IncidenciaListadoModel incidencia;
  final VoidCallback? onTap;

  const _IncidenciaCard({required this.incidencia, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final estadoColor = switch (incidencia.estadoIncidencia) {
      'RESUELTA' => Colors.green,
      'RECHAZADA' => colors.error,
      'CANCELADA' => colors.onSurfaceVariant,
      'EN_ATENCION' => colors.primary,
      'EN_REVISION' => Colors.orange,
      _ => colors.secondary,
    };

    final prioridadColor = switch (incidencia.prioridad) {
      'CRITICA' => colors.error,
      'ALTA' => Colors.orange,
      'MEDIA' => colors.primary,
      _ => Colors.green,
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reporte #${incidencia.idIncidencia}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                incidencia.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _badge(
                    incidencia.estadoIncidencia.split('_').join(' '),
                    estadoColor,
                  ),
                  _badge(
                    'Prioridad ${incidencia.prioridad.toLowerCase()}',
                    prioridadColor,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                incidencia.tipo.split('_').join(' '),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                incidencia.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),

              if (incidencia.direccionReferencia != null &&
                  incidencia.direccionReferencia!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _info(
                  context,
                  Icons.location_on_outlined,
                  incidencia.direccionReferencia!,
                ),
              ],

              const SizedBox(height: 12),

              _info(
                context,
                Icons.person_outline_rounded,
                incidencia.responsable?.username ?? 'Sin responsable asignado',
              ),

              const SizedBox(height: 8),

              _info(
                context,
                Icons.schedule_rounded,
                _formatearFecha(incidencia.fechaReporte),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _info(BuildContext context, IconData icon, String texto) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String _formatearFecha(String value) {
    final fecha = DateTime.tryParse(value)?.toLocal();

    if (fecha == null) {
      return 'Fecha no disponible';
    }

    String dos(int numero) => numero.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
        '${dos(fecha.hour)}:${dos(fecha.minute)}';
  }
}
