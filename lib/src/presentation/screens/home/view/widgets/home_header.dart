import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String nombreConductor;
  final DateTime fecha;
  final bool cargando;
  final VoidCallback onActualizar;

  const HomeHeader({
    super.key,
    required this.nombreConductor,
    required this.fecha,
    required this.cargando,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final nombre = nombreConductor.trim().isEmpty
        ? 'Conductor'
        : nombreConductor.trim();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.local_shipping_outlined,
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_saludo(), style: theme.textTheme.bodyMedium),
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_fechaTexto(fecha), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: cargando ? null : onActualizar,
            tooltip: 'Actualizar jornada',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  String _saludo() {
    final hora = DateTime.now().hour;

    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';

    return 'Buenas noches';
  }

  String _fechaTexto(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${dias[fecha.weekday - 1]}, '
        '${fecha.day} de ${meses[fecha.month - 1]}';
  }
}
