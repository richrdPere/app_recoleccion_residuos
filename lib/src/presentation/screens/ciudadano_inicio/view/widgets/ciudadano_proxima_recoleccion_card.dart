import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/ciudadanos/get_domicilio_cronograma_model.dart';

class CiudadanoProximaRecoleccionCard extends StatelessWidget {
  final GetDomicilioCronogramaDataModel? cronograma;
  final bool cargando;
  final String? error;

  final VoidCallback? onReintentar;
  final VoidCallback? onVerMapa;

  const CiudadanoProximaRecoleccionCard({
    super.key,
    required this.cronograma,
    this.cargando = false,
    this.error,
    this.onReintentar,
    this.onVerMapa,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final proxima = cronograma?.proximaRecoleccion;
    final ruta = cronograma?.domicilio.ruta?.nombre;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: colors.onPrimaryContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 30,
                    color: colors.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Próxima recolección',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (cargando) ...[
                LinearProgressIndicator(
                  color: colors.onPrimaryContainer,
                  backgroundColor: colors.onPrimaryContainer.withValues(
                    alpha: 0.12,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Consultando el cronograma...'),
              ] else if (error != null) ...[
                Text(
                  'Cronograma no disponible',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(error!),
                if (onReintentar != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onReintentar,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ] else if (proxima == null) ...[
                const Text(
                  'No hay una próxima recolección disponible '
                  'en el cronograma de este domicilio.',
                ),
                if (onReintentar != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onReintentar,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Actualizar cronograma'),
                  ),
                ],
              ] else ...[
                Text(
                  _etiqueta(proxima.diaSemana),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _fecha(proxima.fecha),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '${_hora(proxima.horaInicio)}'
                  ' – ${_hora(proxima.horaFin)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text('Frecuencia: ${_etiqueta(proxima.frecuencia)}'),

                if (ruta?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text('Ruta: $ruta'),
                ],

                const SizedBox(height: 16),

                const Text(
                  'Horario de referencia del cronograma. '
                  'No representa una hora estimada de llegada del camión.',
                ),

                if (onVerMapa != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onVerMapa,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Abrir mapa'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _etiqueta(String valor) {
    final texto = valor.replaceAll('_', ' ').trim().toLowerCase();

    if (texto.isEmpty) return 'No disponible';

    return '${texto[0].toUpperCase()}${texto.substring(1)}';
  }

  String _fecha(String valor) {
    // Fecha de calendario: no convertir a hora local.
    final fecha = DateTime.tryParse(valor);
    if (fecha == null) return valor;

    String dos(int numero) => numero.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}';
  }

  String _hora(String valor) {
    return valor.length >= 5 ? valor.substring(0, 5) : valor;
  }
}
