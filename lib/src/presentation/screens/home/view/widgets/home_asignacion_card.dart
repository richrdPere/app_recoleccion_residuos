import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class HomeAsignacionCard extends StatelessWidget {
  final MiAsignacionModel asignacion;

  final bool mostrarAceptar;
  final bool aceptando;
  final bool bloqueado;

  final VoidCallback? onAceptar;
  final VoidCallback? onSeleccionarRecorrido;
  // final bool respondiendo;

  const HomeAsignacionCard({
    super.key,
    required this.asignacion,

    // this.respondiendo = false,
    this.mostrarAceptar = false,
    this.aceptando = false,
    this.bloqueado = false,
    this.onAceptar,
    this.onSeleccionarRecorrido,
  });

  @override
  Widget build(BuildContext context) {
    final programacion = asignacion.programacion;
    final puedeSeleccionarRecorrido =
        asignacion.funcion == 'CONDUCTOR' &&
        asignacion.esPrincipal &&
        asignacion.estadoAsignacion == 'ACEPTADO' &&
        programacion.estadoProgramacion == 'ACEPTADA';
    final theme = Theme.of(context);

    final observacion = programacion.observacion?.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Programación #${asignacion.idProgramacion}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text(_etiqueta(asignacion.estadoAsignacion))),
                Chip(label: Text(_etiqueta(programacion.estadoProgramacion))),
              ],
            ),

            const SizedBox(height: 8),

            _dato(
              Icons.schedule,
              '${_hora(programacion.horaInicioProgramada)}'
              ' – '
              '${_hora(programacion.horaFinProgramada)}',
            ),
            _dato(
              Icons.wb_sunny_outlined,
              'Turno: ${_etiqueta(programacion.turno)}',
            ),
            _dato(Icons.route_outlined, 'Ruta #${programacion.idRuta}'),
            _dato(
              Icons.local_shipping_outlined,
              'Vehículo #${programacion.idVehiculo}',
            ),
            _dato(
              Icons.badge_outlined,
              'Función: ${_etiqueta(asignacion.funcion)}',
            ),

            if (observacion != null && observacion.isNotEmpty) ...[
              const Divider(height: 24),
              Text(observacion),
            ],

            if (mostrarAceptar || aceptando) ...[
              const Divider(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: bloqueado || aceptando ? null : onAceptar,
                  icon: aceptando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    aceptando ? 'Aceptando...' : 'Aceptar programación',
                  ),
                ),
              ),
            ],

            if (puedeSeleccionarRecorrido &&
                onSeleccionarRecorrido != null) ...[
              const Divider(height: 24),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: bloqueado || aceptando
                      ? null
                      : () {
                          // Solicita el detalle de la programación seleccionada.
                          onSeleccionarRecorrido!();

                          // Abre la pantalla del mapa.
                          context.goNamed('mi_recorrido');
                        },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ir a mi recorrido'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }

  String _etiqueta(String valor) {
    return valor.replaceAll('_', ' ');
  }

  String _hora(String valor) {
    final coincidencia = RegExp(r'^(\d{2}):(\d{2})').firstMatch(valor);

    if (coincidencia == null) return valor;

    return '${coincidencia.group(1)}:'
        '${coincidencia.group(2)}';
  }
}
