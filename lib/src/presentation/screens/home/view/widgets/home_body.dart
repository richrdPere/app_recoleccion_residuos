import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

import 'home_programacion_section.dart';

class HomeBody extends StatelessWidget {
  final bool cargando;
  final MisAsignacionesDataModel? datos;
  final String? error;

  final VoidCallback onActualizar;
  final VoidCallback? onVerProgramaciones;

  final bool bloqueandoRespuestas;
  final int? idAsignacionRespondiendo;

  final bool Function(MiAsignacionModel) puedeAceptarAsignacion;

  final ValueChanged<MiAsignacionModel> onAceptarAsignacion;

  final ValueChanged<MiAsignacionModel> onSeleccionarRecorrido;

  final Widget? actividadReciente;

  const HomeBody({
    super.key,
    required this.cargando,
    required this.datos,
    required this.error,
    required this.onActualizar,
    required this.bloqueandoRespuestas,
    required this.idAsignacionRespondiendo,
    required this.puedeAceptarAsignacion,
    required this.onAceptarAsignacion,
    required this.onSeleccionarRecorrido,
    this.onVerProgramaciones,
    this.actividadReciente,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeProgramacionSection(
            cargando: cargando,
            datos: datos,
            error: error,
            onActualizar: onActualizar,
            bloqueandoRespuestas: bloqueandoRespuestas,
            idAsignacionRespondiendo: idAsignacionRespondiendo,
            puedeAceptarAsignacion: puedeAceptarAsignacion,
            onAceptarAsignacion: onAceptarAsignacion,
            onSeleccionarRecorrido: onSeleccionarRecorrido,
          ),

          const SizedBox(height: 28),

          if (actividadReciente != null) ...[
            Text(
              'Actividad reciente',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            actividadReciente!,
          ] else if (onVerProgramaciones != null) ...[
            Text(
              'Tus programaciones',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Color(0xFF009CD8),
                  ),
                ),
                title: const Text(
                  'Consultar programaciones',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Accede al listado de tus asignaciones.'),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF009CD8),
                ),
                onTap: onVerProgramaciones,
              ),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'En Mi recorrido encontrarás el mapa '
                  'y las acciones de tu servicio.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// // Modelos
// import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// // Widgets
// import 'home_asignacion_card.dart';

// class HomeBody extends StatelessWidget {
//   final bool cargando;
//   final MisAsignacionesDataModel? datos;
//   final String? error;

//   final VoidCallback onActualizar;
//   final VoidCallback? onVerProgramaciones;

//   // Acción que recibirá la asignación seleccionada.
//   final ValueChanged<MiAsignacionModel>? onResponderAsignacion;

//   // Reglas y estado proporcionados por la pantalla/BLoC.
//   final bool Function(MiAsignacionModel)? puedeResponderAsignacion;
//   final bool Function(MiAsignacionModel)? estaRespondiendoAsignacion;

//   final bool bloqueandoRespuestas;
//   final int? idAsignacionRespondiendo;

//   final bool Function(MiAsignacionModel) puedeAceptarAsignacion;

//   final ValueChanged<MiAsignacionModel> onAceptarAsignacion;

//   final ValueChanged<MiAsignacionModel> onSeleccionarRecorrido;

//   const HomeBody({
//     super.key,
//     required this.cargando,
//     required this.datos,
//     required this.error,
//     required this.onActualizar,
//     required this.bloqueandoRespuestas,
//     required this.idAsignacionRespondiendo,
//     required this.puedeAceptarAsignacion,
//     required this.onAceptarAsignacion,
//     required this.onSeleccionarRecorrido,
//     this.onVerProgramaciones,
//     this.onResponderAsignacion,
//     this.puedeResponderAsignacion,
//     this.estaRespondiendoAsignacion,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (cargando) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final mensajeError = error;

//     if (mensajeError != null) {
//       return _estadoVacio(
//         icono: Icons.cloud_off_outlined,
//         titulo: 'No pudimos cargar tu jornada',
//         mensaje: mensajeError,
//         accion: FilledButton.icon(
//           onPressed: onActualizar,
//           icon: const Icon(Icons.refresh),
//           label: const Text('Reintentar'),
//         ),
//       );
//     }

//     final data = datos;

//     if (data == null) {
//       return _estadoVacio(
//         icono: Icons.info_outline,
//         titulo: 'Información no disponible',
//         mensaje: 'Actualiza para consultar tus asignaciones.',
//         accion: FilledButton(
//           onPressed: onActualizar,
//           child: const Text('Actualizar'),
//         ),
//       );
//     }

//     if (data.items.isEmpty) {
//       return _estadoVacio(
//         icono: Icons.event_available_outlined,
//         titulo: 'Sin asignaciones para hoy',
//         mensaje:
//             'Cuando te asignen una programación '
//             'podrás consultarla aquí.',
//         accion: OutlinedButton.icon(
//           onPressed: onActualizar,
//           icon: const Icon(Icons.refresh),
//           label: const Text('Actualizar'),
//         ),
//       );
//     }

//     // Ordena únicamente los elementos recibidos en esta página.
//     final asignaciones = [...data.items]
//       ..sort(
//         (a, b) => a.programacion.horaInicioProgramada.compareTo(
//           b.programacion.horaInicioProgramada,
//         ),
//       );

//     final theme = Theme.of(context);

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Card(
//           margin: EdgeInsets.zero,
//           color: theme.colorScheme.primaryContainer,
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.assignment_outlined,
//                   size: 36,
//                   color: theme.colorScheme.onPrimaryContainer,
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Tu jornada de hoy',
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           color: theme.colorScheme.onPrimaryContainer,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${data.pagination.total} asignaciones',
//                         style: theme.textTheme.headlineSmall?.copyWith(
//                           color: theme.colorScheme.onPrimaryContainer,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 24),

//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 'Asignaciones de hoy',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             if (onVerProgramaciones != null)
//               TextButton(
//                 onPressed: onVerProgramaciones,
//                 child: const Text('Ver todas'),
//               ),
//           ],
//         ),

//         if (data.pagination.total > asignaciones.length)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Text(
//               'Mostrando ${asignaciones.length} '
//               'de ${data.pagination.total} asignaciones.',
//               style: theme.textTheme.bodySmall,
//             ),
//           ),

//         for (final asignacion in asignaciones)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: HomeAsignacionCard(
//               key: ValueKey(asignacion.idProgramacionPersonal),
//               asignacion: asignacion,

//               mostrarAceptar: puedeAceptarAsignacion(asignacion),

//               aceptando:
//                   idAsignacionRespondiendo == asignacion.idProgramacionPersonal,

//               bloqueado: bloqueandoRespuestas,

//               onAceptar: () {
//                 onAceptarAsignacion(asignacion);
//               },

//               onSeleccionarRecorrido: () {
//                 onSeleccionarRecorrido(asignacion);
//               },
//             ),
//           ),
//         const SizedBox(height: 8),

//         const Card(
//           margin: EdgeInsets.zero,
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.info_outline),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Revisa tu programación antes de salir. '
//                     'En Mi recorrido encontrarás el mapa '
//                     'y las acciones de tu servicio.',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _crearTarjetaAsignacion(MiAsignacionModel asignacion) {
//   //   final responder = onResponderAsignacion;

//   //   final puedeResponder = puedeResponderAsignacion?.call(asignacion) ?? false;

//   //   final respondiendo = estaRespondiendoAsignacion?.call(asignacion) ?? false;

//   //   return HomeAsignacionCard(
//   //     asignacion: asignacion,
//   //     respondiendo: respondiendo,
//   //     onResponder: responder != null && puedeResponder
//   //         ? () => responder(asignacion)
//   //         : null,
//   //   );
//   // }

//   Widget _estadoVacio({
//     required IconData icono,
//     required String titulo,
//     required String mensaje,
//     required Widget accion,
//   }) {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icono, size: 56),
//             const SizedBox(height: 16),
//             Text(
//               titulo,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(mensaje, textAlign: TextAlign.center),
//             const SizedBox(height: 20),
//             accion,
//           ],
//         ),
//       ),
//     );
//   }
// }
