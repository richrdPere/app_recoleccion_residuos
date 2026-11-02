import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/incidencias/get_incidencia_paginado.model.dart';

import 'ciudadano_reporte_item.dart';

class CiudadanoReportesRecientes extends StatelessWidget {
  final List<IncidenciaListadoModel> reportes;

  final bool cargando;
  final String? error;

  final ValueChanged<IncidenciaListadoModel> onAbrirReporte;
  final VoidCallback onVerTodos;
  final VoidCallback? onReintentar;
  final VoidCallback? onCrearReporte;

  const CiudadanoReportesRecientes({
    super.key,
    required this.reportes,
    required this.onAbrirReporte,
    required this.onVerTodos,
    this.cargando = false,
    this.error,
    this.onReintentar,
    this.onCrearReporte,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final recientes = reportes.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mis reportes recientes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(onPressed: onVerTodos, child: const Text('Ver todos')),
          ],
        ),

        const SizedBox(height: 8),

        if (cargando) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
        ],

        if (error != null) ...[
          Text(error!, style: TextStyle(color: colors.error)),
          if (recientes.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text('Se muestran los últimos reportes consultados.'),
          ],
          if (onReintentar != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: cargando ? null : onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ),
          const SizedBox(height: 8),
        ],

        if (recientes.isNotEmpty)
          for (final reporte in recientes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CiudadanoReporteItem(
                key: ValueKey(reporte.idIncidencia),
                reporte: reporte,
                onTap: () => onAbrirReporte(reporte),
              ),
            )
        else if (cargando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Consultando tus reportes...',
              textAlign: TextAlign.center,
            ),
          )
        else if (error == null)
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: colors.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 40,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no tienes reportes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Puedes reportar problemas relacionados '
                    'con la recolección de residuos.',
                    textAlign: TextAlign.center,
                  ),
                  if (onCrearReporte != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: onCrearReporte,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear reporte'),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
