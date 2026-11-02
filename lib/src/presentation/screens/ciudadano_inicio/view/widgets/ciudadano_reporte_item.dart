import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/incidencias/get_incidencia_paginado.model.dart';

class CiudadanoReporteItem extends StatelessWidget {
  final IncidenciaListadoModel reporte;
  final VoidCallback onTap;

  const CiudadanoReporteItem({
    super.key,
    required this.reporte,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final estado = reporte.estadoIncidencia.trim().toUpperCase();

    final (Color, Color) coloresEstado = switch (estado) {
      'RESUELTA' => (colors.secondaryContainer, colors.onSecondaryContainer),
      'RECHAZADA' => (colors.errorContainer, colors.onErrorContainer),
      'EN_ATENCION' => (colors.tertiaryContainer, colors.onTertiaryContainer),
      _ => (colors.primaryContainer, colors.onPrimaryContainer),
    };

    final (fondoEstado, textoEstado) = coloresEstado;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.report_outlined, color: colors.onPrimaryContainer),
        ),
        title: Text(
          reporte.titulo.trim().isEmpty
              ? 'Reporte #${reporte.idIncidencia}'
              : reporte.titulo.trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${reporte.idIncidencia}'
                ' · ${_fecha(reporte.fechaReporte)}',
                style: theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: fondoEstado,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _etiqueta(estado),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textoEstado,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: colors.primary),
      ),
    );
  }

  String _etiqueta(String valor) {
    final texto = valor.replaceAll('_', ' ').trim().toLowerCase();
    if (texto.isEmpty) return 'Sin estado';

    return '${texto[0].toUpperCase()}${texto.substring(1)}';
  }

  String _fecha(String valor) {
    final fecha = DateTime.tryParse(valor)?.toLocal();
    if (fecha == null) return 'Fecha no disponible';

    String dos(int numero) => numero.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}'
        ' ${dos(fecha.hour)}:${dos(fecha.minute)}';
  }
}
