import 'package:flutter/material.dart';

import 'mapa_accion_boton.dart';

class MapaAccionesLaterales extends StatelessWidget {
  // *********************************************************
  // CONTROLES DEL MAPA
  // *********************************************************

  final VoidCallback? onCentrarUbicacion;
  final VoidCallback? onAjustarRuta;

  final bool centrandoUbicacion;
  final bool ajustandoRuta;

  // *********************************************************
  // ACCIONES DEL RECORRIDO
  // *********************************************************

  final bool puedeIniciar;
  final bool puedePausar;
  final bool puedeReanudar;

  final bool procesandoRecorrido;

  final VoidCallback? onIniciarRecorrido;
  final VoidCallback? onPausarRecorrido;
  final VoidCallback? onReanudarRecorrido;

  // *********************************************************
  // OPERACIONES ADICIONALES
  // *********************************************************

  final bool mostrarOperaciones;
  final VoidCallback? onAbrirOperaciones;

  const MapaAccionesLaterales({
    super.key,
    required this.onCentrarUbicacion,
    required this.onAjustarRuta,
    this.centrandoUbicacion = false,
    this.ajustandoRuta = false,
    this.puedeIniciar = false,
    this.puedePausar = false,
    this.puedeReanudar = false,
    this.procesandoRecorrido = false,
    this.onIniciarRecorrido,
    this.onPausarRecorrido,
    this.onReanudarRecorrido,
    this.mostrarOperaciones = true,
    this.onAbrirOperaciones,
  }) : assert(
         !(puedeIniciar && puedePausar) &&
             !(puedeIniciar && puedeReanudar) &&
             !(puedePausar && puedeReanudar),
         'Solo una acción principal puede estar disponible.',
       );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final mostrarAccionPrincipal = puedeIniciar || puedePausar || puedeReanudar;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ***********************************************
          // CENTRAR UBICACIÓN
          // ***********************************************
          MapaAccionBoton(
            icono: Icons.my_location_rounded,
            tooltip: 'Centrar mi ubicación',
            onPressed: onCentrarUbicacion,
            cargando: centrandoUbicacion,
            colorIcono: colors.primary,
          ),

          const SizedBox(height: 10),

          // ***********************************************
          // MOSTRAR TODA LA RUTA
          // ***********************************************
          MapaAccionBoton(
            icono: Icons.fit_screen_rounded,
            tooltip: 'Mostrar toda la ruta',
            onPressed: onAjustarRuta,
            cargando: ajustandoRuta,
            colorIcono: colors.onSurface,
          ),

          if (mostrarAccionPrincipal) ...[
            const SizedBox(height: 22),

            // *********************************************
            // INICIAR RECORRIDO
            // *********************************************
            if (puedeIniciar)
              MapaAccionBoton(
                icono: Icons.play_arrow_rounded,
                tooltip: 'Iniciar recorrido',
                onPressed: onIniciarRecorrido,
                cargando: procesandoRecorrido,
                colorFondo: const Color(0xFF187749),
                colorIcono: Colors.white,
              ),

            // *********************************************
            // PAUSAR RECORRIDO
            // *********************************************
            if (puedePausar)
              MapaAccionBoton(
                icono: Icons.pause_rounded,
                tooltip: 'Pausar recorrido',
                onPressed: onPausarRecorrido,
                cargando: procesandoRecorrido,
                colorFondo: const Color(0xFFFFCF70),
                colorIcono: const Color(0xFF4A3300),
              ),

            // *********************************************
            // REANUDAR RECORRIDO
            // *********************************************
            if (puedeReanudar)
              MapaAccionBoton(
                icono: Icons.play_arrow_rounded,
                tooltip: 'Reanudar recorrido',
                onPressed: onReanudarRecorrido,
                cargando: procesandoRecorrido,
                colorFondo: const Color(0xFF006A9B),
                colorIcono: Colors.white,
              ),
          ],

          // ***********************************************
          // ABRIR PANEL DE OPERACIONES
          // ***********************************************
          if (mostrarOperaciones) ...[
            SizedBox(height: mostrarAccionPrincipal ? 10 : 22),
            MapaAccionBoton(
              icono: Icons.grid_view_rounded,
              tooltip: 'Operaciones del recorrido',
              onPressed: procesandoRecorrido ? null : onAbrirOperaciones,
              colorIcono: colors.onSurface,
            ),
          ],
        ],
      ),
    );
  }
}
