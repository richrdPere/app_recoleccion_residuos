import 'dart:async';
import 'package:flutter/material.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

typedef MostrarMensajeRecorrido =
    void Function(String mensaje, {VoidCallback? accion});

class MapaRecorridoController extends ChangeNotifier {
  final RecorridoBloc recorridoBloc;
  final GeolocatorBloc geolocatorBloc;

  // Consultan los valores actuales de la página.
  final int? Function() obtenerIdProgramacion;
  final bool Function() programacionFinalizada;
  final bool Function() ubicacionPendiente;

  final MostrarMensajeRecorrido onMensaje;
  final ValueChanged<UbicacionEntity> onUbicacionObtenida;

  final VoidCallback abrirConfiguracionAplicacion;
  final VoidCallback abrirConfiguracionUbicacion;

  late final StreamSubscription<RecorridoState> _suscripcion;

  bool _preparandoAccion = false;
  bool _accionEncolada = false;
  bool _disposed = false;

  MapaRecorridoController({
    required this.recorridoBloc,
    required this.geolocatorBloc,
    required this.obtenerIdProgramacion,
    required this.programacionFinalizada,
    required this.ubicacionPendiente,
    required this.onMensaje,
    required this.onUbicacionObtenida,
    required this.abrirConfiguracionAplicacion,
    required this.abrirConfiguracionUbicacion,
  }) {
    _suscripcion = recorridoBloc.stream.listen((state) {
      if (_disposed) return;

      // El BLoC ya comenzó a procesar el evento enviado.
      // Desde aquí isProcessingAccion mantiene el bloqueo.
      if (state.isProcessingAccion) {
        _accionEncolada = false;
      }

      notifyListeners();
    });
  }

  // *********************************************************
  // ESTADO
  // *********************************************************

  bool get preparandoAccion => _preparandoAccion || _accionEncolada;

  bool get operacionOcupada =>
      _disposed ||
      recorridoBloc.isClosed ||
      geolocatorBloc.isClosed ||
      preparandoAccion ||
      ubicacionPendiente() ||
      recorridoBloc.state.isProcessingAccion ||
      recorridoBloc.state.isLoadingActivo;

  void _notificar() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // *********************************************************
  // EJECUTAR ACCIÓN
  // *********************************************************

  Future<void> ejecutar(BuildContext context, RecorridoAccion accion) async {
    if (!context.mounted || operacionOcupada) return;

    final estadoInicial = recorridoBloc.state;
    final recorridoInicial = estadoInicial.recorridoActivo;
    final idProgramacion = obtenerIdProgramacion();

    if (!_activoConocido(estadoInicial)) {
      onMensaje('Actualiza el recorrido activo antes de continuar.');
      return;
    }

    if (accion == RecorridoAccion.iniciar) {
      if (recorridoInicial != null) {
        onMensaje('Ya tienes un recorrido activo.');
        return;
      }

      if (idProgramacion == null ||
          idProgramacion <= 0 ||
          programacionFinalizada()) {
        onMensaje('Selecciona una programación pendiente.');
        return;
      }
    } else {
      if (recorridoInicial == null) {
        onMensaje('No tienes un recorrido activo.');
        return;
      }

      if (!_accionPermitida(accion, recorridoInicial.estadoRecorrido)) {
        onMensaje('Esta acción no corresponde al estado del recorrido.');
        return;
      }
    }

    _preparandoAccion = true;
    _notificar();

    try {
      final confirmado = await _confirmar(context, accion);

      if (_disposed || !context.mounted || !confirmado) return;

      UbicacionEntity? posicion;

      if (accion == RecorridoAccion.iniciar ||
          accion == RecorridoAccion.finalizar) {
        posicion = await _obtenerPosicion();

        if (_disposed || posicion == null) return;
      }

      if (_disposed || recorridoBloc.isClosed) return;

      // Revisar nuevamente después del diálogo y de obtener GPS.
      final estadoActual = recorridoBloc.state;
      final recorridoActual = estadoActual.recorridoActivo;

      if (estadoActual.isProcessingAccion ||
          estadoActual.isLoadingActivo ||
          !_activoConocido(estadoActual)) {
        onMensaje('El recorrido está siendo actualizado. Intenta nuevamente.');
        return;
      }

      if (accion == RecorridoAccion.iniciar) {
        if (recorridoActual != null ||
            obtenerIdProgramacion() != idProgramacion ||
            programacionFinalizada()) {
          onMensaje('La programación o el recorrido cambió. Revisa los datos.');
          return;
        }
      } else {
        if (recorridoActual == null ||
            recorridoActual.idRecorrido != recorridoInicial!.idRecorrido ||
            !_accionPermitida(accion, recorridoActual.estadoRecorrido)) {
          onMensaje('El recorrido cambió. Revisa su estado actual.');
          return;
        }
      }

      final evento = _crearEvento(
        accion: accion,
        idProgramacion: idProgramacion,
        idRecorrido: recorridoActual?.idRecorrido,
        posicion: posicion,
      );

      // Mantener el bloqueo hasta que el BLoC emita Loading.
      _accionEncolada = true;

      try {
        recorridoBloc.add(evento);
      } catch (_) {
        _accionEncolada = false;
        rethrow;
      }
    } catch (_) {
      if (!_disposed) {
        onMensaje('No se pudo preparar la operación del recorrido.');
      }
    } finally {
      _preparandoAccion = false;
      _notificar();
    }
  }

  bool _activoConocido(RecorridoState state) {
    if (state.activoResponse is ErrorData<ApiResponse<RecorridoDataModel?>>) {
      return false;
    }

    return state.activoResponse is Success<ApiResponse<RecorridoDataModel?>> ||
        state.recorridoActivo != null;
  }

  bool _accionPermitida(RecorridoAccion accion, String estadoRecorrido) {
    final estado = estadoRecorrido.trim().toUpperCase();

    switch (accion) {
      case RecorridoAccion.iniciar:
        return false;
      case RecorridoAccion.pausar:
        return estado == 'EN_CURSO';
      case RecorridoAccion.reanudar:
        return estado == 'PAUSADO';
      case RecorridoAccion.finalizar:
        return estado == 'EN_CURSO' || estado == 'PAUSADO';
    }
  }

  // *********************************************************
  // UBICACIÓN NUEVA PARA INICIAR / FINALIZAR
  // *********************************************************

  Future<UbicacionEntity?> _obtenerPosicion() async {
    if (_disposed || geolocatorBloc.isClosed) return null;

    final useCases = geolocatorBloc.geolocatorUseCases;

    final permiso = await useCases.verificarPermiso.run();

    if (_disposed) return null;

    if (permiso is ErrorData<PermisoUbicacion>) {
      onMensaje(permiso.fullMessage);
      return null;
    }

    if (permiso is! Success<PermisoUbicacion>) {
      onMensaje('No se pudo comprobar el permiso de ubicación.');
      return null;
    }

    final autorizado =
        permiso.data == PermisoUbicacion.duranteUso ||
        permiso.data == PermisoUbicacion.siempre;

    if (!autorizado) {
      onMensaje(
        'Habilita el permiso de ubicación antes de continuar.',
        accion: abrirConfiguracionAplicacion,
      );
      return null;
    }

    final servicio = await useCases.estaServicioHabilitado.run();

    if (_disposed) return null;

    if (servicio is ErrorData<bool>) {
      onMensaje(servicio.fullMessage);
      return null;
    }

    if (servicio is! Success<bool>) {
      onMensaje('No se pudo comprobar el servicio de ubicación.');
      return null;
    }

    if (!servicio.data) {
      onMensaje(
        'Activa el GPS antes de continuar.',
        accion: abrirConfiguracionUbicacion,
      );
      return null;
    }

    final resultado = await useCases.obtenerUbicacionActual.run(
      tiempoLimite: const Duration(seconds: 20),
    );

    if (_disposed) return null;

    if (resultado is ErrorData<UbicacionEntity>) {
      onMensaje(resultado.fullMessage);
      return null;
    }

    if (resultado is! Success<UbicacionEntity>) {
      onMensaje('No se pudo obtener una ubicación válida.');
      return null;
    }

    final posicion = resultado.data;
    final latitud = posicion.coordenada.latitud;
    final longitud = posicion.coordenada.longitud;

    if (!latitud.isFinite ||
        !longitud.isFinite ||
        latitud < -90 ||
        latitud > 90 ||
        longitud < -180 ||
        longitud > 180) {
      onMensaje('La ubicación obtenida contiene coordenadas inválidas.');
      return null;
    }

    onUbicacionObtenida(posicion);

    return posicion;
  }

  // *********************************************************
  // CREAR EVENTO
  // *********************************************************

  RecorridoEvent _crearEvento({
    required RecorridoAccion accion,
    required int? idProgramacion,
    required int? idRecorrido,
    required UbicacionEntity? posicion,
  }) {
    final fechaEvento = DateTime.now().toUtc();

    switch (accion) {
      case RecorridoAccion.iniciar:
        final ubicacion = posicion!;

        return IniciarRecorrido(
          idProgramacion: idProgramacion!,
          request: IniciarRecorridoRequest(
            latitud: ubicacion.coordenada.latitud,
            longitud: ubicacion.coordenada.longitud,
            precisionGps: ubicacion.precisionMetros,
            fechaEvento: fechaEvento,
          ),
        );

      case RecorridoAccion.pausar:
        return PausarRecorrido(
          idRecorrido: idRecorrido!,
          request: PausarRecorridoRequest(fechaEvento: fechaEvento),
        );

      case RecorridoAccion.reanudar:
        return ReanudarRecorrido(
          idRecorrido: idRecorrido!,
          request: ReanudarRecorridoRequest(fechaEvento: fechaEvento),
        );

      case RecorridoAccion.finalizar:
        final ubicacion = posicion!;

        return FinalizarRecorrido(
          idRecorrido: idRecorrido!,
          request: FinalizarRecorridoRequest(
            latitud: ubicacion.coordenada.latitud,
            longitud: ubicacion.coordenada.longitud,
            precisionGps: ubicacion.precisionMetros,
            fechaEvento: fechaEvento,
          ),
        );
    }
  }

  // *********************************************************
  // CONFIRMACIÓN
  // *********************************************************

  Future<bool> _confirmar(BuildContext context, RecorridoAccion accion) async {
    final String titulo;
    final String mensaje;

    switch (accion) {
      case RecorridoAccion.iniciar:
        titulo = 'Iniciar recorrido';
        mensaje = '¿Deseas iniciar la programación seleccionada?';
        break;
      case RecorridoAccion.pausar:
        titulo = 'Pausar recorrido';
        mensaje = '¿Deseas pausar el recorrido actual?';
        break;
      case RecorridoAccion.reanudar:
        titulo = 'Reanudar recorrido';
        mensaje = '¿Deseas continuar el recorrido actual?';
        break;
      case RecorridoAccion.finalizar:
        titulo = 'Finalizar recorrido';
        mensaje = '¿Deseas dar por finalizado el recorrido actual?';
        break;
    }

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(titulo),
              content: Text(mensaje),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // *********************************************************
  // LIMPIEZA
  // *********************************************************

  @override
  void dispose() {
    _disposed = true;

    unawaited(_suscripcion.cancel());

    // Los BLoC globales no se cierran aquí.
    super.dispose();
  }
}
