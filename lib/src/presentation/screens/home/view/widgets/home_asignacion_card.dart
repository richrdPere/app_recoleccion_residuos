import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class HomeAsignacionCard extends StatelessWidget {
  final MiAsignacionModel asignacion;

  final bool mostrarAceptar;
  final bool aceptando;
  final bool bloqueado;

  final VoidCallback? onAceptar;
  final VoidCallback? onSeleccionarRecorrido;

  static const _celeste = Color(0xFF00AEEF);

  const HomeAsignacionCard({
    super.key,
    required this.asignacion,
    this.mostrarAceptar = false,
    this.aceptando = false,
    this.bloqueado = false,
    this.onAceptar,
    this.onSeleccionarRecorrido,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final programacion = asignacion.programacion;

    final estadoAsignacion = asignacion.estadoAsignacion.trim().toUpperCase();

    final estadoProgramacion = programacion.estadoProgramacion
        .trim()
        .toUpperCase();

    // Conserva la condición de selección de tu tarjeta anterior.
    final puedeSeleccionarRecorrido =
        asignacion.funcion.trim().toUpperCase() == 'CONDUCTOR' &&
        asignacion.esPrincipal &&
        estadoAsignacion == 'ACEPTADO' &&
        estadoProgramacion == 'ACEPTADA';

    final observacion = programacion.observacion?.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ***********************************************
          // IDENTIFICACIÓN DE LA RUTA
          // ***********************************************
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _celeste.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: _celeste,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Programación #${asignacion.idProgramacion}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      programacion.ruta.nombre,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ruta ${programacion.ruta.codigo}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ***********************************************
          // ESTADOS
          // ***********************************************
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _estado(
                texto: 'Asignación: ${_etiqueta(estadoAsignacion)}',
                color: _colorEstado(estadoAsignacion),
              ),
              _estado(
                texto: 'Programación: ${_etiqueta(estadoProgramacion)}',
                color: _colorEstado(estadoProgramacion),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ***********************************************
          // HORARIO DESTACADO
          // ***********************************************
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _celeste.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: _celeste, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horario de recolección',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_hora(programacion.horaInicioProgramada)}'
                        ' – '
                        '${_hora(programacion.horaFinProgramada)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ***********************************************
          // DATOS OPERATIVOS
          // ***********************************************
          _dato(
            context,
            icono: Icons.calendar_today_outlined,
            etiqueta: 'Fecha',
            valor: _fecha(programacion.fechaProgramada),
          ),
          _dato(
            context,
            icono: Icons.wb_sunny_outlined,
            etiqueta: 'Turno',
            valor: _etiqueta(programacion.turno),
          ),
          _dato(
            context,
            icono: Icons.local_shipping_outlined,
            etiqueta: 'Vehículo',
            valor: programacion.vehiculo.placa,
          ),
          _dato(
            context,
            icono: Icons.badge_outlined,
            etiqueta: 'Función',
            valor: _etiqueta(asignacion.funcion),
          ),

          if (observacion != null && observacion.isNotEmpty) ...[
            const Divider(height: 28),
            Text(
              'Observaciones',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              observacion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],

          // ***********************************************
          // ACEPTACIÓN
          // ***********************************************
          if (mostrarAceptar || aceptando) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: bloqueado || aceptando ? null : onAceptar,
                style: FilledButton.styleFrom(
                  backgroundColor: _celeste,
                  foregroundColor: const Color(0xFF102A43),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: aceptando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(aceptando ? 'Aceptando…' : 'Aceptar programación'),
              ),
            ),
          ],

          // ***********************************************
          // ACCESO AL RECORRIDO
          // ***********************************************
          if (puedeSeleccionarRecorrido && onSeleccionarRecorrido != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: bloqueado || aceptando
                    ? null
                    : onSeleccionarRecorrido,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ir a mi recorrido'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dato(
    BuildContext context, {
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 19, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              etiqueta,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
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

  Widget _estado({required String texto, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'ACEPTADO':
      case 'ACEPTADA':
        return const Color(0xFF187749);

      case 'EN_CURSO':
        return const Color(0xFF006A9B);

      case 'CANCELADO':
      case 'CANCELADA':
      case 'RECHAZADO':
      case 'RECHAZADA':
      case 'RETIRADO':
        return const Color(0xFFB3261E);

      case 'FINALIZADO':
      case 'FINALIZADA':
      case 'COMPLETADO':
      case 'COMPLETADA':
        return const Color(0xFF52616B);

      default:
        return const Color(0xFF8A5700);
    }
  }

  String _etiqueta(String valor) {
    final texto = valor.replaceAll('_', ' ').trim();

    if (texto.isEmpty) return 'Sin definir';

    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  String _hora(String valor) {
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(valor);

    if (match == null) return valor;

    return '${match.group(1)}:${match.group(2)}';
  }

  String _fecha(String valor) {
    // El contrato utiliza una fecha de servicio YYYY-MM-DD.
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(valor);

    if (match == null) return valor;

    return '${match.group(3)}/${match.group(2)}/${match.group(1)}';
  }
}
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// // Modelos
// import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// class HomeAsignacionCard extends StatelessWidget {
//   final MiAsignacionModel asignacion;

//   final bool mostrarAceptar;
//   final bool aceptando;
//   final bool bloqueado;

//   final VoidCallback? onAceptar;
//   final VoidCallback? onSeleccionarRecorrido;
//   // final bool respondiendo;

//   const HomeAsignacionCard({
//     super.key,
//     required this.asignacion,

//     // this.respondiendo = false,
//     this.mostrarAceptar = false,
//     this.aceptando = false,
//     this.bloqueado = false,
//     this.onAceptar,
//     this.onSeleccionarRecorrido,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final programacion = asignacion.programacion;
//     final puedeSeleccionarRecorrido =
//         asignacion.funcion == 'CONDUCTOR' &&
//         asignacion.esPrincipal &&
//         asignacion.estadoAsignacion == 'ACEPTADO' &&
//         programacion.estadoProgramacion == 'ACEPTADA';
//     final theme = Theme.of(context);

//     final observacion = programacion.observacion?.trim();

//     return Card(
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Programación #${asignacion.idProgramacion}',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Wrap(
//               spacing: 8,
//               runSpacing: 4,
//               children: [
//                 Chip(label: Text(_etiqueta(asignacion.estadoAsignacion))),
//                 Chip(label: Text(_etiqueta(programacion.estadoProgramacion))),
//               ],
//             ),

//             const SizedBox(height: 8),

//             _dato(
//               Icons.schedule,
//               '${_hora(programacion.horaInicioProgramada)}'
//               ' – '
//               '${_hora(programacion.horaFinProgramada)}',
//             ),
//             _dato(
//               Icons.wb_sunny_outlined,
//               'Turno: ${_etiqueta(programacion.turno)}',
//             ),
//             _dato(Icons.route_outlined, 'Ruta #${programacion.idRuta}'),
//             _dato(
//               Icons.local_shipping_outlined,
//               'Vehículo #${programacion.idVehiculo}',
//             ),
//             _dato(
//               Icons.badge_outlined,
//               'Función: ${_etiqueta(asignacion.funcion)}',
//             ),

//             if (observacion != null && observacion.isNotEmpty) ...[
//               const Divider(height: 24),
//               Text(observacion),
//             ],

//             if (mostrarAceptar || aceptando) ...[
//               const Divider(height: 24),

//               SizedBox(
//                 width: double.infinity,
//                 child: FilledButton.icon(
//                   onPressed: bloqueado || aceptando ? null : onAceptar,
//                   icon: aceptando
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Icon(Icons.check_circle_outline),
//                   label: Text(
//                     aceptando ? 'Aceptando...' : 'Aceptar programación',
//                   ),
//                 ),
//               ),
//             ],

//             if (puedeSeleccionarRecorrido &&
//                 onSeleccionarRecorrido != null) ...[
//               const Divider(height: 24),

//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: bloqueado || aceptando
//                       ? null
//                       : () {
//                           // Solicita el detalle de la programación seleccionada.
//                           onSeleccionarRecorrido!();

//                           // Abre la pantalla del mapa.
//                           context.goNamed('mi_recorrido');
//                         },
//                   icon: const Icon(Icons.map_outlined),
//                   label: const Text('Ir a mi recorrido'),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dato(IconData icono, String texto) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icono, size: 18),
//           const SizedBox(width: 10),
//           Expanded(child: Text(texto)),
//         ],
//       ),
//     );
//   }

//   String _etiqueta(String valor) {
//     return valor.replaceAll('_', ' ');
//   }

//   String _hora(String valor) {
//     final coincidencia = RegExp(r'^(\d{2}):(\d{2})').firstMatch(valor);

//     if (coincidencia == null) return valor;

//     return '${coincidencia.group(1)}:'
//         '${coincidencia.group(2)}';
//   }
// }
