import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/recorrido/mis-recorridos/mis_recorridos_model.dart';

class HistorialRecorridoTile extends StatelessWidget {
  final MiRecorridoItemModel recorrido;
  final VoidCallback onTap;
  final bool habilitado;

  const HistorialRecorridoTile({
    super.key,
    required this.recorrido,
    required this.onTap,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final ruta = recorrido.programacion.ruta;
    final vehiculo = recorrido.programacion.vehiculo;

    final nombreRuta = ruta.nombre.trim().isEmpty
        ? 'Ruta sin nombre'
        : ruta.nombre.trim();

    final codigoRuta = ruta.codigo.trim();
    final placa = vehiculo.placa.trim();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: ListTile(
        enabled: habilitado,
        onTap: habilitado ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        minLeadingWidth: 44,
        horizontalTitleGap: 12,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.route_rounded,
            color: colors.onPrimaryContainer,
            size: 24,
          ),
        ),
        title: Text(
          nombreRuta,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  'Recorrido #${recorrido.idRecorrido}',
                  if (codigoRuta.isNotEmpty) codigoRuta,
                ].join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 10),

              _HistorialDato(
                icon: Icons.schedule_rounded,
                texto: _fecha(recorrido.fechaHoraInicio),
              ),

              const SizedBox(height: 6),

              _HistorialDato(
                icon: Icons.local_shipping_outlined,
                texto: placa.isEmpty
                    ? 'Vehículo #${vehiculo.idVehiculo}'
                    : 'Placa: $placa',
              ),

              const SizedBox(height: 12),

              HistorialRecorridoEstado(estado: recorrido.estadoRecorrido),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 28,
          color: habilitado ? colors.primary : colors.onSurfaceVariant,
        ),
      ),
    );
  }

  String _fecha(String valor) {
    final fecha = DateTime.tryParse(valor)?.toLocal();

    if (fecha == null) return 'Fecha no disponible';

    String dos(int numero) => numero.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}'
        ' · ${dos(fecha.hour)}:${dos(fecha.minute)}';
  }
}

// *********************************************************
// DATO BREVE DEL RECORRIDO
// *********************************************************

class _HistorialDato extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _HistorialDato({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: colors.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// *********************************************************
// ESTADO DEL RECORRIDO
// Puede reutilizarse en la pantalla de detalle.
// *********************************************************

class HistorialRecorridoEstado extends StatelessWidget {
  final String estado;

  const HistorialRecorridoEstado({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final estadoNormalizado = estado.trim().toUpperCase();

    final (String, IconData, Color, Color) configuracion =
        switch (estadoNormalizado) {
          'EN_CURSO' => (
            'En curso',
            Icons.play_circle_outline_rounded,
            colors.primaryContainer,
            colors.onPrimaryContainer,
          ),
          'PAUSADO' => (
            'Pausado',
            Icons.pause_circle_outline_rounded,
            colors.tertiaryContainer,
            colors.onTertiaryContainer,
          ),
          'FINALIZADO' => (
            'Finalizado',
            Icons.check_circle_outline_rounded,
            colors.secondaryContainer,
            colors.onSecondaryContainer,
          ),
          'CANCELADO' => (
            'Cancelado',
            Icons.cancel_outlined,
            colors.errorContainer,
            colors.onErrorContainer,
          ),
          _ => (
            estadoNormalizado.isEmpty
                ? 'Sin estado'
                : estadoNormalizado.replaceAll('_', ' '),
            Icons.info_outline_rounded,
            colors.surfaceContainerHighest,
            colors.onSurfaceVariant,
          ),
        };

    final (texto, icono, fondo, contenido) = configuracion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: contenido),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              style: theme.textTheme.labelMedium?.copyWith(
                color: contenido,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
