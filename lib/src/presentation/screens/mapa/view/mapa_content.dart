import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'widgets/geolocator_acceso_widget.dart';
import 'widgets/mapa_app_bar.dart';
import 'widgets/mapa_buscador.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/mapa/view/widgets/mapa_resultado_busqueda_item.dart';
import 'widgets/mapa_acciones_laterales.dart';
import 'widgets/mapa_controles.dart';
import 'widgets/mapa_recorrido_controles.dart';
import 'widgets/mapa_recorrido_resumen.dart';

class MapaContent extends StatelessWidget {
  final Widget mapaBase;

  final String? userId;

  final TextEditingController busquedaController;
  final String consultaBusqueda;

  final bool mostrarResultados;
  final bool ubicacionPendiente;

  final UbicacionEntity? ubicacion;
  final DireccionGeograficaEntity? destino;

  final VoidCallback onBuscarDestino;
  final ValueChanged<String> onBuscarDestinoTexto;

  final ValueChanged<DireccionGeograficaEntity> onSeleccionarDestino;

  final VoidCallback onSolicitarUbicacion;
  final VoidCallback onConsultarDireccion;
  final VoidCallback onCalcularRuta;

  final VoidCallback onAbrirConfiguracionUbicacion;
  final VoidCallback onAbrirConfiguracionAplicacion;

  // Nuevas acciones visuales.
  final VoidCallback? onVolver;
  final VoidCallback? onCentrarUbicacion;
  final VoidCallback? onAjustarRuta;

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
    required this.userId,
    required this.busquedaController,
    required this.consultaBusqueda,
    required this.mostrarResultados,
    required this.ubicacionPendiente,
    required this.ubicacion,
    required this.destino,
    required this.onBuscarDestino,
    required this.onBuscarDestinoTexto,
    required this.onSeleccionarDestino,
    required this.onSolicitarUbicacion,
    required this.onConsultarDireccion,
    required this.onCalcularRuta,
    required this.onAbrirConfiguracionUbicacion,
    required this.onAbrirConfiguracionAplicacion,
    required this.onGeolocator,
    required this.onDirections,
    required this.onGeocoding,
    this.onVolver,
    this.onCentrarUbicacion,
    this.onAjustarRuta,
    this.idProgramacion,
    this.estadoRecorrido,
    this.preparandoAccionRecorrido = false,
    this.onIniciarRecorrido,
    this.onPausarRecorrido,
    this.onReanudarRecorrido,
    this.onFinalizarRecorrido,
  });

  // *********************************************************
  // PANEL INFERIOR DE OPERACIONES
  // *********************************************************

  Future<void> _abrirOperaciones(BuildContext context) async {
    final route = ModalRoute.of(context);

    if (route?.isCurrent != true) return;

    // Reutilizar los BLoCs actuales, sin crear nuevas instancias.
    final recorridoBloc = context.read<RecorridoBloc>();
    final geolocatorBloc = context.read<GeolocatorBloc>();
    final directionsBloc = context.read<DirectionsBloc>();
    final geocodingBloc = context.read<GeocodingBloc>();

    final accion = await showModalBottomSheet<VoidCallback>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        // Devuelve la acción y cierra este panel.
        // La acción se ejecuta después, desde la página.
        VoidCallback? seleccionar(VoidCallback? callback) {
          if (callback == null) return null;

          return () {
            Navigator.of(sheetContext).pop<VoidCallback>(callback);
          };
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<RecorridoBloc>.value(value: recorridoBloc),
            BlocProvider<GeolocatorBloc>.value(value: geolocatorBloc),
            BlocProvider<DirectionsBloc>.value(value: directionsBloc),
            BlocProvider<GeocodingBloc>.value(value: geocodingBloc),
          ],
          child: FractionallySizedBox(
            heightFactor: 0.80,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operaciones del recorrido',
                      style: Theme.of(sheetContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gestiona el servicio y las opciones del mapa.',
                      style: Theme.of(sheetContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    ),

                    const SizedBox(height: 20),

                    MapaRecorridoControles(
                      idProgramacion: idProgramacion,
                      estadoRecorrido: estadoRecorrido,
                      preparandoAccion: preparandoAccionRecorrido,
                      onIniciar: seleccionar(onIniciarRecorrido),
                      onPausar: seleccionar(onPausarRecorrido),
                      onReanudar: seleccionar(onReanudarRecorrido),
                      onFinalizar: seleccionar(onFinalizarRecorrido),
                    ),

                    const SizedBox(height: 16),

                    MapaControles(
                      ubicacionPendiente: ubicacionPendiente,
                      ubicacion: ubicacion,
                      destino: destino,
                      onSolicitarUbicacion: seleccionar(onSolicitarUbicacion)!,
                      onAbrirConfiguracionUbicacion: seleccionar(
                        onAbrirConfiguracionUbicacion,
                      )!,
                      onAbrirConfiguracionAplicacion: seleccionar(
                        onAbrirConfiguracionAplicacion,
                      )!,
                      onConsultarDireccion: seleccionar(onConsultarDireccion)!,
                      onCalcularRuta: seleccionar(onCalcularRuta)!,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted || route?.isCurrent != true) {
      return;
    }

    // Evita abrir un formulario o diálogo encima
    // del panel de operaciones todavía activo.
    accion?.call();
  }

  Widget _construirResumen(BuildContext context) {
    return BlocBuilder<RecorridoBloc, RecorridoState>(
      builder: (context, recorridoState) {
        return BlocBuilder<ProgramacionesBloc, ProgramacionesState>(
          builder: (context, programacionesState) {
            final recorrido = recorridoState.recorridoActivo;

            final programacionId = recorrido?.idProgramacion ?? idProgramacion;

            final resultado = programacionesState.programacionDetalle;

            ProgramacionDetalleDataModel? detalle;

            if (resultado
                is Success<ApiResponse<ProgramacionDetalleDataModel>>) {
              final data = resultado.data.data;

              if (resultado.data.success &&
                  data != null &&
                  data.idProgramacion == programacionId) {
                detalle = data;
              }
            }

            final consultandoDetalle =
                programacionId != null &&
                programacionesState.idProgramacionDetalle == programacionId &&
                programacionesState.cargandoDetalle;

            final cargando =
                recorridoState.isLoadingActivo || consultandoDetalle;

            String? error;

            final activoResponse = recorridoState.activoResponse;

            if (activoResponse is ErrorData<ApiResponse<RecorridoDataModel?>>) {
              error = 'No se pudo actualizar el recorrido activo.';
            } else if (programacionId != null &&
                programacionesState.idProgramacionDetalle == programacionId &&
                resultado
                    is ErrorData<ApiResponse<ProgramacionDetalleDataModel>>) {
              error = 'No se pudieron actualizar los datos de la programación.';
            }

            return MapaRecorridoResumen(
              recorrido: recorrido,
              programacion: detalle,
              idProgramacion: programacionId,
              cargando: cargando,
              error: error,
              onActualizar: recorridoState.isProcessingAccion
                  ? null
                  : () {
                      if (!recorridoState.isLoadingActivo) {
                        context.read<RecorridoBloc>().add(
                          const ObtenerRecorridoActivo(),
                        );
                      }

                      if (programacionId != null &&
                          !programacionesState.cargandoDetalle) {
                        context.read<ProgramacionesBloc>().add(
                          ObtenerProgramacionDetalle(
                            idProgramacion: programacionId,
                          ),
                        );
                      }
                    },
            );
          },
        );
      },
    );
  }

  // *********************************************************
  // INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final tecladoVisible = media.viewInsets.bottom > 0;

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
        extendBodyBehindAppBar: true,
        appBar: MapaAppBar(onVolver: onVolver),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // El body se extiende detrás del AppBar:
            // reservar manualmente su espacio y el área del sistema.
            final inicioPanel = media.padding.top + kToolbarHeight + 8;

            final espacioDisponible =
                (constraints.maxHeight - inicioPanel - media.padding.bottom)
                    .clamp(0.0, double.infinity)
                    .toDouble();

            final alturaPanel =
                espacioDisponible * (tecladoVisible ? 0.80 : 0.40);

            final inicioBotones = inicioPanel + alturaPanel + 8;

            final margenInferior = media.padding.bottom + 12;

            final alturaResumen = (espacioDisponible * 0.34)
                .clamp(0.0, 190.0)
                .toDouble();

            final margenInferiorBotones = margenInferior + alturaResumen + 12;

            final hayEspacioParaBotones =
                constraints.maxHeight - inicioBotones - margenInferiorBotones >
                0;

            return Stack(
              children: [
                // ***************************************
                // MAPA
                // ***************************************
                Positioned.fill(child: mapaBase),

                // ***************************************
                // GPS, BUSCADOR Y RESULTADOS
                // ***************************************
                Positioned(
                  top: inicioPanel,
                  left: 12,
                  right: 12,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: alturaPanel),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GeolocatorAccesoWidget(),

                          Builder(
                            builder: (context) {
                              final usuarioId = userId;

                              if (usuarioId == null ||
                                  usuarioId.trim().isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 8),

                                  MapaBuscador(
                                    userId: usuarioId,
                                    consulta: consultaBusqueda,
                                    onBuscar: onBuscarDestinoTexto,
                                  ),

                                  if (mostrarResultados) ...[
                                    const SizedBox(height: 10),

                                    MapaResultadosBusqueda(
                                      onSeleccionarDestino:
                                          onSeleccionarDestino,
                                      onReintentar: onBuscarDestino,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ***************************************
                // BOTONES LATERALES
                // ***************************************
                if (!tecladoVisible && hayEspacioParaBotones)
                  Positioned(
                    top: inicioBotones,
                    bottom: margenInferiorBotones,
                    right: 6,
                    width: 64,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: BlocBuilder<RecorridoBloc, RecorridoState>(
                        builder: (context, state) {
                          final recorrido = state.recorridoActivo;

                          final estado = recorrido?.estadoRecorrido
                              .trim()
                              .toUpperCase();

                          final enCurso = estado == 'EN_CURSO';

                          final pausado = estado == 'PAUSADO';

                          final consultaFallida =
                              state.activoResponse
                                  is ErrorData<
                                    ApiResponse<RecorridoDataModel?>
                                  >;

                          final activoConsultado =
                              state.activoResponse
                                  is Success<
                                    ApiResponse<RecorridoDataModel?>
                                  > ||
                              recorrido != null;

                          final ocupado =
                              preparandoAccionRecorrido ||
                              state.isProcessingAccion ||
                              state.isLoadingActivo;

                          final puedeOperar =
                              !ocupado && !consultaFallida && activoConsultado;

                          final tieneProgramacion =
                              idProgramacion != null && idProgramacion! > 0;

                          final mostrarIniciar =
                              recorrido == null &&
                              tieneProgramacion &&
                              activoConsultado &&
                              !consultaFallida &&
                              !state.isLoadingActivo;

                          return MapaAccionesLaterales(
                            onCentrarUbicacion:
                                onCentrarUbicacion ?? onSolicitarUbicacion,

                            onAjustarRuta: onAjustarRuta,

                            centrandoUbicacion: ubicacionPendiente,

                            puedeIniciar: mostrarIniciar,
                            puedePausar: enCurso,
                            puedeReanudar: pausado,

                            procesandoRecorrido: ocupado,

                            onIniciarRecorrido: puedeOperar
                                ? onIniciarRecorrido
                                : null,

                            onPausarRecorrido: puedeOperar
                                ? onPausarRecorrido
                                : null,

                            onReanudarRecorrido: puedeOperar
                                ? onReanudarRecorrido
                                : null,

                            onAbrirOperaciones: () {
                              _abrirOperaciones(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                // ***********************************************
                // RESUMEN INFERIOR DEL SERVICIO
                // ***********************************************
                if (!tecladoVisible && alturaResumen > 0)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: margenInferior,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: alturaResumen),
                      child: _construirResumen(context),
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
