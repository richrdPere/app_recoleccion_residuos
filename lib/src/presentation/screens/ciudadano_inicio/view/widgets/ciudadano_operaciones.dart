import 'package:flutter/material.dart';

import 'ciudadano_operacion_item.dart';

class CiudadanoOperaciones extends StatelessWidget {
  final VoidCallback? onVerMapa;
  final VoidCallback? onReportarIncidencia;
  final VoidCallback? onVerHorarios;

  const CiudadanoOperaciones({
    super.key,
    required this.onVerMapa,
    required this.onReportarIncidencia,
    required this.onVerHorarios,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.primary,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Qué deseas hacer?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                const separacion = 12.0;

                final columnas = constraints.maxWidth < 280 ? 2 : 3;

                final anchoItem =
                    (constraints.maxWidth - separacion * (columnas - 1)) /
                    columnas;

                Widget operacion({
                  required IconData icono,
                  required String titulo,
                  required VoidCallback? onTap,
                }) {
                  return SizedBox(
                    width: anchoItem,
                    child: CiudadanoOperacionItem(
                      icono: icono,
                      titulo: titulo,
                      onTap: onTap,
                      colorTexto: colors.onPrimary,
                      colorIcono: colors.primary,
                      colorFondoIcono: colors.surface,
                    ),
                  );
                }

                return Wrap(
                  spacing: separacion,
                  runSpacing: 8,
                  children: [
                    operacion(
                      icono: Icons.local_shipping_outlined,
                      titulo: 'Ver camión',
                      onTap: onVerMapa,
                    ),
                    operacion(
                      icono: Icons.add_location_alt_outlined,
                      titulo: 'Reportar incidencia',
                      onTap: onReportarIncidencia,
                    ),
                    operacion(
                      icono: Icons.calendar_month_outlined,
                      titulo: 'Ver horarios',
                      onTap: onVerHorarios,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
