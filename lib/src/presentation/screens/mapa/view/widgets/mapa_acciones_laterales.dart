import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';

class MapaAccionesLaterales extends StatelessWidget {
  final VoidCallback? onCentrarUbicacion;
  final VoidCallback? onAjustarRuta;
  final VoidCallback? onAbrirOperaciones;

  final bool centrandoUbicacion;
  final bool procesandoRecorrido;

  // Determinan qué acciones se muestran.
  final bool puedeIniciar;
  final bool puedePausar;
  final bool puedeReanudar;
  final bool puedeFinalizar;

  final VoidCallback? onIniciarRecorrido;
  final VoidCallback? onPausarRecorrido;
  final VoidCallback? onReanudarRecorrido;
  final VoidCallback? onFinalizarRecorrido;

  const MapaAccionesLaterales({
    super.key,
    required this.onCentrarUbicacion,
    required this.onAbrirOperaciones,
    this.onAjustarRuta,
    this.centrandoUbicacion = false,
    this.procesandoRecorrido = false,
    this.puedeIniciar = false,
    this.puedePausar = false,
    this.puedeReanudar = false,
    this.puedeFinalizar = false,
    this.onIniciarRecorrido,
    this.onPausarRecorrido,
    this.onReanudarRecorrido,
    this.onFinalizarRecorrido,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final conductor =
        context.watch<SessionBloc>().state.user?.esConductor == true;

    // Recibe la altura disponible desde MapaContent.
    // En pantallas pequeñas permite desplazar los controles.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapaBotonLateral(
            icono: Icons.my_location_rounded,
            tooltip: 'Centrar mi ubicación',
            cargando: centrandoUbicacion,
            onPressed: centrandoUbicacion ? null : onCentrarUbicacion,
          ),

          const SizedBox(height: 8),

          _MapaBotonLateral(
            icono: Icons.fit_screen_rounded,
            tooltip: 'Ver ruta completa',
            onPressed: onAjustarRuta,
          ),

          if (conductor && (puedeIniciar || puedePausar || puedeReanudar)) ...[
            const SizedBox(height: 16),

            if (puedeIniciar)
              _MapaBotonLateral(
                icono: Icons.play_arrow_rounded,
                tooltip: 'Iniciar recorrido',
                fondo: colors.primaryContainer,
                contenido: colors.onPrimaryContainer,
                onPressed: procesandoRecorrido ? null : onIniciarRecorrido,
              ),

            if (puedePausar)
              _MapaBotonLateral(
                icono: Icons.pause_rounded,
                tooltip: 'Pausar recorrido',
                fondo: colors.tertiaryContainer,
                contenido: colors.onTertiaryContainer,
                onPressed: procesandoRecorrido ? null : onPausarRecorrido,
              ),

            if (puedeReanudar)
              _MapaBotonLateral(
                icono: Icons.play_arrow_rounded,
                tooltip: 'Reanudar recorrido',
                fondo: colors.primaryContainer,
                contenido: colors.onPrimaryContainer,
                onPressed: procesandoRecorrido ? null : onReanudarRecorrido,
              ),
          ],

          if (conductor && puedeFinalizar) ...[
            const SizedBox(height: 8),

            _MapaBotonLateral(
              icono: Icons.stop_circle_outlined,
              tooltip: 'Finalizar recorrido',
              fondo: colors.errorContainer,
              contenido: colors.onErrorContainer,
              onPressed: procesandoRecorrido ? null : onFinalizarRecorrido,
            ),
          ],

          const SizedBox(height: 16),

          _MapaBotonLateral(
            icono: Icons.tune_rounded,
            tooltip: 'Operaciones del recorrido',
            onPressed: procesandoRecorrido ? null : onAbrirOperaciones,
          ),

          if (procesandoRecorrido) ...[
            const SizedBox(height: 10),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapaBotonLateral extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? fondo;
  final Color? contenido;
  final bool cargando;

  const _MapaBotonLateral({
    required this.icono,
    required this.tooltip,
    required this.onPressed,
    this.fondo,
    this.contenido,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: fondo ?? colors.surface,
          foregroundColor: contenido ?? colors.primary,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
          elevation: 3,
          shadowColor: colors.shadow.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: cargando
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: contenido ?? colors.primary,
                ),
              )
            : Icon(icono, size: 26),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// import 'mapa_accion_boton.dart';

// class MapaAccionesLaterales extends StatelessWidget {
//   // *********************************************************
//   // CONTROLES DEL MAPA
//   // *********************************************************

//   final VoidCallback? onCentrarUbicacion;
//   final VoidCallback? onAjustarRuta;

//   final bool centrandoUbicacion;
//   final bool ajustandoRuta;

//   // *********************************************************
//   // ACCIONES DEL RECORRIDO
//   // *********************************************************

//   final bool puedeIniciar;
//   final bool puedePausar;
//   final bool puedeReanudar;

//   final bool procesandoRecorrido;

//   final VoidCallback? onIniciarRecorrido;
//   final VoidCallback? onPausarRecorrido;
//   final VoidCallback? onReanudarRecorrido;

//   // *********************************************************
//   // OPERACIONES ADICIONALES
//   // *********************************************************

//   final bool mostrarOperaciones;
//   final VoidCallback? onAbrirOperaciones;

//   const MapaAccionesLaterales({
//     super.key,
//     required this.onCentrarUbicacion,
//     required this.onAjustarRuta,
//     this.centrandoUbicacion = false,
//     this.ajustandoRuta = false,
//     this.puedeIniciar = false,
//     this.puedePausar = false,
//     this.puedeReanudar = false,
//     this.procesandoRecorrido = false,
//     this.onIniciarRecorrido,
//     this.onPausarRecorrido,
//     this.onReanudarRecorrido,
//     this.mostrarOperaciones = true,
//     this.onAbrirOperaciones,
//   }) : assert(
//          !(puedeIniciar && puedePausar) &&
//              !(puedeIniciar && puedeReanudar) &&
//              !(puedePausar && puedeReanudar),
//          'Solo una acción principal puede estar disponible.',
//        );

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;

//     final mostrarAccionPrincipal = puedeIniciar || puedePausar || puedeReanudar;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(6),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ***********************************************
//           // CENTRAR UBICACIÓN
//           // ***********************************************
//           MapaAccionBoton(
//             icono: Icons.my_location_rounded,
//             tooltip: 'Centrar mi ubicación',
//             onPressed: onCentrarUbicacion,
//             cargando: centrandoUbicacion,
//             colorIcono: colors.primary,
//           ),

//           const SizedBox(height: 10),

//           // ***********************************************
//           // MOSTRAR TODA LA RUTA
//           // ***********************************************
//           MapaAccionBoton(
//             icono: Icons.fit_screen_rounded,
//             tooltip: 'Mostrar toda la ruta',
//             onPressed: onAjustarRuta,
//             cargando: ajustandoRuta,
//             colorIcono: colors.onSurface,
//           ),

//           if (mostrarAccionPrincipal) ...[
//             const SizedBox(height: 22),

//             // *********************************************
//             // INICIAR RECORRIDO
//             // *********************************************
//             if (puedeIniciar)
//               MapaAccionBoton(
//                 icono: Icons.play_arrow_rounded,
//                 tooltip: 'Iniciar recorrido',
//                 onPressed: onIniciarRecorrido,
//                 cargando: procesandoRecorrido,
//                 colorFondo: const Color(0xFF187749),
//                 colorIcono: Colors.white,
//               ),

//             // *********************************************
//             // PAUSAR RECORRIDO
//             // *********************************************
//             if (puedePausar)
//               MapaAccionBoton(
//                 icono: Icons.pause_rounded,
//                 tooltip: 'Pausar recorrido',
//                 onPressed: onPausarRecorrido,
//                 cargando: procesandoRecorrido,
//                 colorFondo: const Color(0xFFFFCF70),
//                 colorIcono: const Color(0xFF4A3300),
//               ),

//             // *********************************************
//             // REANUDAR RECORRIDO
//             // *********************************************
//             if (puedeReanudar)
//               MapaAccionBoton(
//                 icono: Icons.play_arrow_rounded,
//                 tooltip: 'Reanudar recorrido',
//                 onPressed: onReanudarRecorrido,
//                 cargando: procesandoRecorrido,
//                 colorFondo: const Color(0xFF006A9B),
//                 colorIcono: Colors.white,
//               ),
//           ],

//           // ***********************************************
//           // ABRIR PANEL DE OPERACIONES
//           // ***********************************************
//           if (mostrarOperaciones) ...[
//             SizedBox(height: mostrarAccionPrincipal ? 10 : 22),
//             MapaAccionBoton(
//               icono: Icons.grid_view_rounded,
//               tooltip: 'Operaciones del recorrido',
//               onPressed: procesandoRecorrido ? null : onAbrirOperaciones,
//               colorIcono: colors.onSurface,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
