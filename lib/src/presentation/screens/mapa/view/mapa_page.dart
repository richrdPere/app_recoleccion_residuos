import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs y mapa base
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Controllers
import 'controllers/mapa_dibujo_controller.dart';
import 'controllers/mapa_ubicacion_controller.dart';
import 'controllers/mapa_geocoding_controller.dart';
import 'controllers/mapa_directions_controller.dart';
import 'controllers/mapa_recorrido_controller.dart';
import 'controllers/mapa_tracking_controller.dart';

// Content
import 'mapa_content.dart';

// ==========================================================
// MAPA PAGE
// Utiliza los BLoC registrados globalmente.
// ==========================================================

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  // *********************************************************
  // CONTROLLERS
  // *********************************************************

  final _busquedaController = TextEditingController();

  late final MapaDibujoController _dibujoController;
  late final MapaUbicacionController _ubicacionController;
  late final MapaGeocodingController _geocodingController;
  late final MapaDirectionsController _directionsController;
  late final MapaRecorridoController _recorridoController;
  late final MapaTrackingController _trackingController;

  // *********************************************************
  // MAPA Y DATOS VISUALES
  // *********************************************************

  late final Widget _mapaBase;
  late final RecorridoBloc _recorridoBloc;

  UbicacionEntity? _ubicacion;
  DireccionGeograficaEntity? _destino;
  RutaCalculadaEntity? _ruta;

  bool _mostrarResultados = false;

  final bool _preparandoAccionRecorrido = false;

  bool _programacionFinalizada = false;

  // *********************************************************
  // INICIALIZACIÓN
  // *********************************************************

  @override
  void initState() {
    super.initState();

    _recorridoBloc = context.read<RecorridoBloc>();

    _recorridoBloc.add(const ObtenerRecorridoActivo());

    // 1. Dibujo y cámara.
    _dibujoController = MapaDibujoController(
      onError: (mensaje) => _mensaje(mensaje),
    );

    // 2. Cálculo de caminos.
    _directionsController = MapaDirectionsController(
      directionsBloc: context.read<DirectionsBloc>(),
      onMensaje: (mensaje) => _mensaje(mensaje),
      onRutaActualizada: _onRutaActualizada,
    );

    // 3. Búsqueda y consulta de direcciones.
    _geocodingController = MapaGeocodingController(
      geocodingBloc: context.read<GeocodingBloc>(),
      onMensaje: (mensaje) => _mensaje(mensaje),
      onMostrarResultados: _cambiarMostrarResultados,
      onDestinoSeleccionado: _onDestinoSeleccionado,
    );

    // 4. GPS y permisos.
    _ubicacionController = MapaUbicacionController(
      geolocatorBloc: context.read<GeolocatorBloc>(),
      onMensaje: _mensaje,
      onUbicacionObtenida: _onUbicacionObtenida,
    );

    _ubicacionController.addListener(_refrescarEstadoUbicacion);

    // 5. Acciones de recorrido

    _recorridoController = MapaRecorridoController(
      recorridoBloc: _recorridoBloc,
      geolocatorBloc: context.read<GeolocatorBloc>(),

      // Se leen al ejecutar cada acción, sin copiar los valores.
      obtenerIdProgramacion: () => _idProgramacionSeleccionada,
      programacionFinalizada: () => _programacionFinalizada,
      ubicacionPendiente: () => _ubicacionController.ubicacionPendiente,

      onMensaje: _mensaje,
      onUbicacionObtenida: _onUbicacionObtenida,

      abrirConfiguracionAplicacion:
          _ubicacionController.abrirConfiguracionAplicacion,
      abrirConfiguracionUbicacion:
          _ubicacionController.abrirConfiguracionUbicacion,
    );

    _recorridoController.addListener(_refrescarEstadoRecorrido);

    _recorridoBloc.add(const ObtenerRecorridoActivo());

    // 6. Tracking
    _trackingController = MapaTrackingController(
      recorridoBloc: _recorridoBloc,
      trackingBloc: context.read<TrackingBloc>(),

      obtenerUbicacion: () {
        return context
            .read<GeolocatorBloc>()
            .geolocatorUseCases
            .obtenerUbicacionActual
            .run(tiempoLimite: const Duration(seconds: 20));
      },

      onMensaje: (mensaje) {
        _mensaje(mensaje);
      },
    );

    // Se conserva la misma instancia del widget del mapa.
    _mapaBase = MapaBaseConBloc(
      onMapCreated: _dibujoController.asociarMapa,
      onStyleLoaded: _dibujoController.prepararAnotaciones,
    );

    _recorridoBloc.add(const ObtenerRecorridoActivo());

    // // Consultar el estado actual del GPS.
    // context.read<GeolocatorBloc>().add(const VerificarServicioGeolocator());

    // // Consultar el permiso ya concedido por el usuario.
    // context.read<GeolocatorBloc>().add(const VerificarPermisoGeolocator());

    // Limpiar los resultados de consultas anteriores.
    context.read<DirectionsBloc>().add(const LimpiarRutaDirections());

    context.read<GeocodingBloc>().add(const LimpiarGeocoding());

    // // Obtener el recorrido activo
    // context.read<RecorridoBloc>().add(const ObtenerRecorridoActivo());
  }

  // *********************************************************
  // ACCIONES
  // *********************************************************

  void _buscarDestino() {
    FocusScope.of(context).unfocus();

    _geocodingController.buscarDestino(
      texto: _busquedaController.text,
      proximidad: _ubicacion?.coordenada,
    );
  }

  void _seleccionarDestino(DireccionGeograficaEntity destino) {
    FocusScope.of(context).unfocus();

    _geocodingController.seleccionarDestino(destino);
  }

  void _consultarMiDireccion() {
    _geocodingController.consultarMiDireccion(_ubicacion);
  }

  void _calcularRuta() {
    _directionsController.calcularRuta(
      ubicacion: _ubicacion,
      destino: _destino,
    );
  }

  // *********************************************************
  // CALLBACKS DE GEOCODING
  // *********************************************************

  void _cambiarMostrarResultados(bool mostrar) {
    if (!mounted || _mostrarResultados == mostrar) return;

    setState(() {
      _mostrarResultados = mostrar;
    });
  }

  void _onDestinoSeleccionado(DireccionGeograficaEntity destino) {
    if (!mounted) return;

    setState(() {
      _destino = destino;
      _ruta = null;
    });

    // Además de limpiar el estado, actualiza los dibujos
    // mediante _onRutaActualizada(null).
    _directionsController.limpiarRuta();

    unawaited(_dibujoController.centrar(destino.coordenada));
  }

  // *********************************************************
  // CALLBACKS DE DIRECTIONS
  // *********************************************************

  void _onRutaActualizada(RutaCalculadaEntity? ruta) {
    if (!mounted) return;

    _ruta = ruta;
    _actualizarDibujos();
  }

  // *********************************************************
  // CALLBACKS DE UBICACIÓN
  // *********************************************************

  void _refrescarEstadoUbicacion() {
    if (!mounted) return;

    setState(() {});
  }

  void _onUbicacionObtenida(UbicacionEntity ubicacion) {
    if (!mounted) return;

    setState(() {
      _ubicacion = ubicacion;
      _ruta = null;
    });

    // Invalida el camino calculado desde la posición anterior
    // y actualiza los dibujos con la nueva ubicación.
    _directionsController.limpiarRuta();

    unawaited(_dibujoController.centrar(ubicacion.coordenada));
  }

  // *********************************************************
  // LISTENERS DE LOS BLOC
  // *********************************************************

  void _onGeocoding(BuildContext context, GeocodingState state) {
    _geocodingController.procesarEstado(state);
  }

  void _onDirections(BuildContext context, DirectionsState state) {
    _directionsController.procesarEstado(state);
  }

  // *********************************************************
  // DIBUJO
  // *********************************************************

  void _actualizarDibujos() {
    _dibujoController.actualizar(
      ubicacion: _ubicacion,
      destino: _destino,
      ruta: _ruta,
    );
  }

  // *********************************************************
  // MENSAJES
  // *********************************************************

  void _mensaje(String mensaje, {VoidCallback? accion}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          action: accion == null
              ? null
              : SnackBarAction(label: 'Abrir', onPressed: accion),
        ),
      );
  }

  void _onRecorrido(BuildContext context, RecorridoState state) {
    final resultado = state.accionResponse;

    if (resultado is Success<ApiResponse<RecorridoDataModel>>) {
      if (state.accion == RecorridoAccion.finalizar) {
        setState(() {
          _programacionFinalizada = true;
        });
      }

      final mensaje = resultado.data.message;

      _mensaje(
        mensaje.isEmpty ? 'Operación realizada correctamente.' : mensaje,
      );
    } else if (resultado is ErrorData<ApiResponse<RecorridoDataModel>>) {
      _mensaje(resultado.fullMessage);
    }
  }

  void _refrescarEstadoRecorrido() {
    if (!mounted) return;

    setState(() {});
  }

  int? _obtenerIdProgramacion(ProgramacionesState state) {
    final id = state.idProgramacionDetalle;
    final resultado = state.programacionDetalle;

    if (id == null || id <= 0) return null;

    if (resultado is! Success<ApiResponse<ProgramacionDetalleDataModel>>) {
      return null;
    }

    if (!resultado.data.success || resultado.data.data == null) {
      return null;
    }

    return id;
  }

  int? get _idProgramacionSeleccionada {
    return _obtenerIdProgramacion(context.read<ProgramacionesBloc>().state);
    // final state = context.read<ProgramacionesBloc>().state;
    // final resultado = state.programacionDetalle;
    // final id = state.idProgramacionDetalle;

    // if (id == null || id <= 0) return null;

    // if (resultado is! Success<ApiResponse<ProgramacionDetalleDataModel>>) {
    //   return null;
    // }

    // if (!resultado.data.success || resultado.data.data == null) {
    //   return null;
    // }

    // return id;
  }

  // *********************************************************
  // LIMPIEZA
  // *********************************************************

  @override
  void dispose() {
    _trackingController.dispose();

    _recorridoController.removeListener(_refrescarEstadoRecorrido);
    _recorridoController.dispose();

    _ubicacionController.removeListener(_refrescarEstadoUbicacion);

    _ubicacionController.dispose();
    _dibujoController.dispose();
    _busquedaController.dispose();

    // Los BLoC globales no se cierran desde esta página.
    super.dispose();
  }

  // *********************************************************
  // UI
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final idProgramacionSeleccionada = context.select<ProgramacionesBloc, int?>(
      (bloc) => _obtenerIdProgramacion(bloc.state),
    );

    return BlocConsumer<RecorridoBloc, RecorridoState>(
      listenWhen: (anterior, actual) =>
          anterior.accionResponse != actual.accionResponse,
      listener: _onRecorrido,
      builder: (context, recorridoState) {
        final recorrido = recorridoState.recorridoActivo;

        return MapaContent(
          mapaBase: _mapaBase,
          busquedaController: _busquedaController,
          mostrarResultados: _mostrarResultados,
          ubicacionPendiente: _ubicacionController.ubicacionPendiente,
          ubicacion: _ubicacion,
          destino: _destino,

          // Acciones del mapa.
          onBuscarDestino: _buscarDestino,
          onSeleccionarDestino: _seleccionarDestino,
          onSolicitarUbicacion: _ubicacionController.solicitarUbicacion,
          onConsultarDireccion: _consultarMiDireccion,
          onCalcularRuta: _calcularRuta,

          // Configuración.
          onAbrirConfiguracionUbicacion:
              _ubicacionController.abrirConfiguracionUbicacion,
          onAbrirConfiguracionAplicacion:
              _ubicacionController.abrirConfiguracionAplicacion,

          // Listeners actuales.
          onDirections: _onDirections,
          onGeocoding: _onGeocoding,
          onGeolocator: (_, __) {},

          // Datos del recorrido.
          idProgramacion: _programacionFinalizada
              ? null
              : idProgramacionSeleccionada,
          estadoRecorrido: recorrido?.estadoRecorrido,
          preparandoAccionRecorrido:
              _preparandoAccionRecorrido ||
              _ubicacionController.ubicacionPendiente,

          // Nuevos callbacks.
          onIniciarRecorrido: () {
            unawaited(
              _recorridoController.ejecutar(context, RecorridoAccion.iniciar),
            );
          },

          onPausarRecorrido: () {
            unawaited(
              _recorridoController.ejecutar(context, RecorridoAccion.pausar),
            );
          },

          onReanudarRecorrido: () {
            unawaited(
              _recorridoController.ejecutar(context, RecorridoAccion.reanudar),
            );
          },

          onFinalizarRecorrido: () {
            unawaited(
              _recorridoController.ejecutar(context, RecorridoAccion.finalizar),
            );
          },
        );
      },
    );
  }
}
