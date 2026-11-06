import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/ciudadanos/get_domicilio_cronograma_model.dart';

class CiudadanoProximaRecoleccionCard extends StatelessWidget {
  final GetDomicilioCronogramaDataModel? cronograma;
  final bool cargando;
  final String? error;

  final VoidCallback? onReintentar;
  final VoidCallback? onVerMapa;
  final VoidCallback? onVerCalendario;

  const CiudadanoProximaRecoleccionCard({
    super.key,
    required this.cronograma,
    this.cargando = false,
    this.error,
    this.onReintentar,
    this.onVerMapa,
    this.onVerCalendario,
  });

  String _fecha(String value) {
    final partes = value.split('-');

    if (partes.length != 3) return value;

    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  String _hora(String value) =>
      value.length >= 5 ? value.substring(0, 5) : value;

  String _dia(String value) {
    const dias = {
      'LUNES': 'Lunes',
      'MARTES': 'Martes',
      'MIERCOLES': 'Miércoles',
      'JUEVES': 'Jueves',
      'VIERNES': 'Viernes',
      'SABADO': 'Sábado',
      'DOMINGO': 'Domingo',
    };

    return dias[value] ?? value;
  }

  Widget _evento(
    BuildContext context, {
    required String titulo,
    required IconData icono,
    required CronogramaEventoModel? evento,
    required String vacio,
    required bool habitual,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icono, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (evento == null)
            Text(vacio)
          else ...[
            Text(
              '${_dia(evento.diaSemana)}, ${_fecha(evento.fecha)}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${_hora(evento.horaInicio)} – ${_hora(evento.horaFin)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (habitual)
              const Text('Horario de referencia, sujeto a programación.')
            else ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(evento.estadoLabel),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Text(
                'La franja del servicio no representa una hora '
                'exacta de llegada a tu domicilio.',
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = cronograma;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tu recolección',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (cargando) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Consultando el cronograma…'),
            ] else if (error != null) ...[
              const Text('Cronograma no disponible'),
              const SizedBox(height: 8),
              Text(error!),
            ] else if (data == null)
              const Text('Todavía no se ha consultado el cronograma.')
            else ...[
              Text(
                data.domicilio.nombreDomicilio,
                style: theme.textTheme.titleMedium,
              ),
              if (data.domicilio.ruta != null)
                Text(data.domicilio.ruta!.nombre),
              const SizedBox(height: 6),
              Text(
                'Periodo: ${_fecha(data.periodo.fechaDesde)}'
                ' – ${_fecha(data.periodo.fechaHasta)}',
              ),
              const SizedBox(height: 16),
              _evento(
                context,
                titulo: 'Próximo servicio programado',
                icono: Icons.local_shipping_outlined,
                evento: data.proximaRecoleccion,
                vacio: 'No hay servicios programados en el periodo consultado.',
                habitual: false,
              ),
              const SizedBox(height: 12),
              _evento(
                context,
                titulo: 'Próximo horario habitual',
                icono: Icons.schedule_outlined,
                evento: data.proximaReferenciaHabitual,
                vacio:
                    'No hay horarios habituales próximos '
                    'en el periodo consultado.',
                habitual: true,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onReintentar != null)
                  OutlinedButton.icon(
                    onPressed: cargando ? null : onReintentar,
                    icon: const Icon(Icons.refresh),
                    label: Text(error != null ? 'Reintentar' : 'Actualizar'),
                  ),
                if (onVerCalendario != null)
                  FilledButton.icon(
                    onPressed: onVerCalendario,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Ver calendario'),
                  ),
                if (onVerMapa != null)
                  OutlinedButton.icon(
                    onPressed: onVerMapa,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Abrir mapa'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
