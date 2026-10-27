import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Widgets
import 'widgets/geolocator_acceso_widget.dart';
import 'widgets/mapa_buscador.dart';
import 'widgets/mapa_controles.dart';
import 'widgets/mapa_recorrido_controles.dart';

class MapaContent extends StatelessWidget {
  final Widget mapaBase;

  final TextEditingController busquedaController;
  final bool mostrarResultados;
  final bool ubicacionPendiente;

  final UbicacionEntity? ubicacion;
  final DireccionGeograficaEntity? destino;

  final VoidCallback onBuscarDestino;
  final ValueChanged<DireccionGeograficaEntity> onSeleccionarDestino;
  final VoidCallback onSolicitarUbicacion;
  final VoidCallback onConsultarDireccion;
  final VoidCallback onCalcularRuta;
  final VoidCallback onAbrirConfiguracionUbicacion;
  final VoidCallback onAbrirConfiguracionAplicacion;

  final void Function(BuildContext, GeolocatorState) onGeolocator;
  final void Function(BuildContext, DirectionsState) onDirections;
  final void Function(BuildContext, GeocodingState) onGeocoding;

  // *********************************************************
  // OPERACIÓN DEL RECORRIDO
  // *********************************************************

  final int? idProgramacion;
  final String? estadoRecorrido;
  final bool preparandoAccionRecorrido;

  final VoidCallback? onIniciarRecorrido;
  final VoidCallback? onPausarRecorrido;
  final VoidCallback? onReanudarRecorrido;
  final VoidCallback? onFinalizarRecorrido;

  const MapaContent({
    super.key,
    required this.mapaBase,
    required this.busquedaController,
    required this.mostrarResultados,
    required this.ubicacionPendiente,
    required this.ubicacion,
    required this.destino,
    required this.onBuscarDestino,
    required this.onSeleccionarDestino,
    required this.onSolicitarUbicacion,
    required this.onConsultarDireccion,
    required this.onCalcularRuta,
    required this.onAbrirConfiguracionUbicacion,
    required this.onAbrirConfiguracionAplicacion,
    required this.onGeolocator,
    required this.onDirections,
    required this.onGeocoding,
    this.idProgramacion,
    this.estadoRecorrido,
    this.preparandoAccionRecorrido = false,
    this.onIniciarRecorrido,
    this.onPausarRecorrido,
    this.onReanudarRecorrido,
    this.onFinalizarRecorrido,
  });

  @override
  Widget build(BuildContext context) {
    final tecladoVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return MultiBlocListener(
      listeners: [
        BlocListener<GeolocatorBloc, GeolocatorState>(listener: onGeolocator),
        BlocListener<DirectionsBloc, DirectionsState>(listener: onDirections),
        BlocListener<GeocodingBloc, GeocodingState>(
          listenWhen: (anterior, actual) =>
              anterior.direccion != actual.direccion,
          listener: onGeocoding,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Mapa del conductor')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(child: mapaBase),

                // *********************************************
                // GPS, PERMISOS Y BUSCADOR
                // *********************************************
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            constraints.maxHeight *
                            (tecladoVisible ? 0.85 : 0.40),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Se mantiene montado aunque aparezca el teclado.
                            const GeolocatorAccesoWidget(),

                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: MapaBuscador(
                                controller: busquedaController,
                                mostrarResultados: mostrarResultados,
                                onBuscar: onBuscarDestino,
                                onSeleccionarDestino: onSeleccionarDestino,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // *********************************************
                // OPERACIÓN Y CONTROLES DEL MAPA
                // *********************************************
                if (!tecladoVisible)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: SafeArea(
                      top: false,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.55,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MapaRecorridoControles(
                                idProgramacion: idProgramacion,
                                estadoRecorrido: estadoRecorrido,
                                preparandoAccion: preparandoAccionRecorrido,
                                onIniciar: onIniciarRecorrido,
                                onPausar: onPausarRecorrido,
                                onReanudar: onReanudarRecorrido,
                                onFinalizar: onFinalizarRecorrido,
                              ),

                              const SizedBox(height: 12),

                              MapaControles(
                                ubicacionPendiente: ubicacionPendiente,
                                ubicacion: ubicacion,
                                destino: destino,
                                onSolicitarUbicacion: onSolicitarUbicacion,
                                onAbrirConfiguracionUbicacion:
                                    onAbrirConfiguracionUbicacion,
                                onAbrirConfiguracionAplicacion:
                                    onAbrirConfiguracionAplicacion,
                                onConsultarDireccion: onConsultarDireccion,
                                onCalcularRuta: onCalcularRuta,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
