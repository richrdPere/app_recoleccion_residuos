import 'package:flutter/material.dart';

// Widgets
import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/view/widgets/notifications_bell.dart';
import 'home_operaciones.dart';

class HomeHeader extends StatelessWidget {
  final String nombreConductor;
  final DateTime fecha;

  final bool cargando;
  final VoidCallback onActualizar;

  final VoidCallback? onAbrirMenu;
  final VoidCallback? onVerIncidencias;
  final VoidCallback? onVerRecolecciones;
  final VoidCallback? onVerProgramaciones;
  final VoidCallback? onVerMas;

  static const Color _colorFondo = Color(0xFF00AEEF);
  static const Color _colorTexto = Color(0xFF102A43);

  const HomeHeader({
    super.key,
    required this.nombreConductor,
    required this.fecha,
    required this.cargando,
    required this.onActualizar,
    this.onAbrirMenu,
    this.onVerIncidencias,
    this.onVerRecolecciones,
    this.onVerProgramaciones,
    this.onVerMas,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = nombreConductor.trim().isEmpty
        ? 'Conductor'
        : nombreConductor.trim();

    return Material(
      color: _colorFondo,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ***************************************
              // SALUDO Y ACCIONES DEL ENCABEZADO
              // ***************************************
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // El menú aparece cuando tiene una
                  // acción conectada desde la página.
                  if (onAbrirMenu != null) ...[
                    IconButton(
                      onPressed: onAbrirMenu,
                      tooltip: 'Abrir menú',
                      style: IconButton.styleFrom(foregroundColor: _colorTexto),
                      icon: const Icon(Icons.menu_rounded, size: 30),
                    ),
                    const SizedBox(width: 4),
                  ],

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, $nombre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _colorTexto,
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_saludo()} · ${_fechaTexto(fecha)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _colorTexto.withValues(alpha: 0.85),
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Reutiliza el contador y la navegación
                  // de notificaciones ya implementados.
                  IconButtonTheme(
                    data: IconButtonThemeData(
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                    child: const NotificationsBell(),
                  ),

                  IconButton(
                    onPressed: cargando ? null : onActualizar,
                    tooltip: cargando
                        ? 'Actualizando jornada'
                        : 'Actualizar jornada',
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                    ),
                    icon: cargando
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 26),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ***************************************
              // OPERACIONES DEL CONDUCTOR
              // ***************************************
              HomeOperaciones(
                colorTexto: _colorTexto,
                colorIcono: _colorFondo,
                onVerIncidencias: onVerIncidencias,
                onVerRecolecciones: onVerRecolecciones,
                onVerProgramaciones: onVerProgramaciones,
                onVerMas: onVerMas,
              ),
            ],
          ),
        ),
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
// import 'package:flutter/material.dart';

// class HomeHeader extends StatelessWidget {
//   final String nombreConductor;
//   final DateTime fecha;
//   final bool cargando;
//   final VoidCallback onActualizar;

//   const HomeHeader({
//     super.key,
//     required this.nombreConductor,
//     required this.fecha,
//     required this.cargando,
//     required this.onActualizar,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final nombre = nombreConductor.trim().isEmpty
//         ? 'Conductor'
//         : nombreConductor.trim();

//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 26,
//             backgroundColor: theme.colorScheme.primaryContainer,
//             child: Icon(
//               Icons.local_shipping_outlined,
//               color: theme.colorScheme.onPrimaryContainer,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(_saludo(), style: theme.textTheme.bodyMedium),
//                 Text(
//                   nombre,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(_fechaTexto(fecha), style: theme.textTheme.bodySmall),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: cargando ? null : onActualizar,
//             tooltip: 'Actualizar jornada',
//             icon: const Icon(Icons.refresh),
//           ),
//         ],
//       ),
//     );
//   }

//   String _saludo() {
//     final hora = DateTime.now().hour;

//     if (hora < 12) return 'Buenos días';
//     if (hora < 19) return 'Buenas tardes';

//     return 'Buenas noches';
//   }

//   String _fechaTexto(DateTime fecha) {
//     const dias = [
//       'Lunes',
//       'Martes',
//       'Miércoles',
//       'Jueves',
//       'Viernes',
//       'Sábado',
//       'Domingo',
//     ];

//     const meses = [
//       'enero',
//       'febrero',
//       'marzo',
//       'abril',
//       'mayo',
//       'junio',
//       'julio',
//       'agosto',
//       'septiembre',
//       'octubre',
//       'noviembre',
//       'diciembre',
//     ];

//     return '${dias[fecha.weekday - 1]}, '
//         '${fecha.day} de ${meses[fecha.month - 1]}';
//   }
// }
