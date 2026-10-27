import 'dart:async';
import 'dart:math';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';
import 'package:flutter/material.dart';

class MapaTrackingController {
  final RecorridoBloc recorridoBloc;
  final TrackingBloc trackingBloc;

  final Future<Resource<UbicacionEntity>> Function() obtenerUbicacion;

  final void Function(String mensaje) onMensaje;

  final Duration intervalo;

  late final StreamSubscription<RecorridoState> _suscripcionRecorrido;

  late RecorridoState _estadoAnterior;

  Timer? _temporizador;

  final Random _random = Random.secure();

  int? _idRecorrido;
  int _generacion = 0;

  bool _enviando = false;
  bool _disposed = false;

  String? _ultimoMensaje;
  DateTime? _fechaUltimoMensaje;

  MapaTrackingController({
    required this.recorridoBloc,
    required this.trackingBloc,
    required this.obtenerUbicacion,
    required this.onMensaje,
    this.intervalo = const Duration(seconds: 10),
  }) {
    _estadoAnterior = recorridoBloc.state;

    _suscripcionRecorrido = recorridoBloc.stream.listen(_procesarRecorrido);

    // Recuperar también un recorrido que ya estuviera cargado
    // antes de crear este controller.
    _sincronizar(recorridoBloc.state.recorridoActivo);
  }

  // ========================================================
  // ESCUCHAR RESULTADOS CONFIRMADOS DEL RECORRIDO
  // ========================================================

  void _procesarRecorrido(RecorridoState state) {
    if (_disposed) return;

    final cambioAccion = state.accionResponse != _estadoAnterior.accionResponse;

    final cambioActivo = state.activoResponse != _estadoAnterior.activoResponse;

    _estadoAnterior = state;

    if (cambioAccion) {
      final resultado = state.accionResponse;

      if (resultado is Success<ApiResponse<RecorridoDataModel>>) {
        if (resultado.data.success) {
          _sincronizar(resultado.data.data);
          return;
        }
      }
    }

    if (cambioActivo) {
      final resultado = state.activoResponse;

      if (resultado is Success<ApiResponse<RecorridoDataModel?>>) {
        if (resultado.data.success) {
          _sincronizar(resultado.data.data);
        }
      }
    }

    // Una acción fallida no cambia el último estado confirmado.
  }

  void _sincronizar(RecorridoDataModel? recorrido) {
    final estado = recorrido?.estadoRecorrido.trim().toUpperCase();

    if (recorrido == null ||
        recorrido.idRecorrido <= 0 ||
        estado != 'EN_CURSO') {
      detener();
      return;
    }

    // No reiniciar el temporizador por cada emisión del BLoC.
    if (_idRecorrido == recorrido.idRecorrido && _temporizador != null) {
      return;
    }

    detener();

    _idRecorrido = recorrido.idRecorrido;

    _temporizador = Timer.periodic(
      intervalo,
      (_) => unawaited(_enviarUbicacion()),
    );

    // Primera muestra sin esperar los 10 segundos.
    unawaited(_enviarUbicacion());
  }

  // ========================================================
  // CAPTURAR Y ENVIAR UNA POSICIÓN
  // ========================================================

  Future<void> _enviarUbicacion() async {
    final idRecorrido = _idRecorrido;

    if (_disposed ||
        idRecorrido == null ||
        _enviando ||
        trackingBloc.isClosed ||
        recorridoBloc.isClosed ||
        trackingBloc.state.procesando ||
        recorridoBloc.state.isProcessingAccion ||
        recorridoBloc.state.isLoadingActivo) {
      return;
    }

    final generacion = _generacion;

    _enviando = true;

    try {
      final resultado = await obtenerUbicacion();

      if (!_sigueVigente(generacion, idRecorrido)) return;

      if (resultado is ErrorData<UbicacionEntity>) {
        _informar(resultado.fullMessage);
        return;
      }

      if (resultado is! Success<UbicacionEntity>) {
        _informar('No se pudo obtener la posición para tracking.');
        return;
      }

      final ubicacion = resultado.data;
      final latitud = ubicacion.coordenada.latitud;
      final longitud = ubicacion.coordenada.longitud;

      debugPrint(
        '[GPS] '
        'fecha=${ubicacion.fechaCaptura.toUtc().toIso8601String()} '
        'lat=${ubicacion.coordenada.latitud} '
        'lng=${ubicacion.coordenada.longitud} '
        'precision=${ubicacion.precisionMetros}m '
        'velocidad=${ubicacion.velocidadMetrosPorSegundo}m/s',
      );

      if (!latitud.isFinite ||
          !longitud.isFinite ||
          latitud < -90 ||
          latitud > 90 ||
          longitud < -180 ||
          longitud > 180) {
        _informar('La posición GPS contiene coordenadas inválidas.');
        return;
      }

      if (ubicacion.esSimulada == true) {
        _informar(
          'El GPS reporta una ubicación simulada. '
          'No se utilizará para el seguimiento en vivo.',
        );
        return;
      }

      final antiguedad = DateTime.now().toUtc().difference(
        ubicacion.fechaCaptura.toUtc(),
      );

      if (antiguedad > const Duration(seconds: 120) ||
          antiguedad < const Duration(seconds: -5)) {
        _informar(
          'La posición GPS no es reciente. '
          'Se intentará obtener otra ubicación.',
        );
        return;
      }

      // Pudo comenzar otra operación mientras se obtenía GPS.
      if (trackingBloc.state.procesando ||
          recorridoBloc.state.isProcessingAccion ||
          recorridoBloc.state.isLoadingActivo) {
        return;
      }

      final rumbo = ubicacion.rumboGrados;

      final request = RegistrarUbicacionRequest(
        idRecorrido: idRecorrido,
        claveIdempotencia: _crearUuid(),
        latitud: latitud,
        longitud: longitud,
        precisionGps: _noNegativo(ubicacion.precisionMetros),
        altitud: _finito(ubicacion.altitudMetros),
        velocidadMps: _noNegativo(ubicacion.velocidadMetrosPorSegundo),
        rumbo: rumbo != null && rumbo.isFinite ? rumbo % 360 : null,
        esUbicacionSimulada: ubicacion.esSimulada ?? false,
        fechaDispositivo: ubicacion.fechaCaptura.toUtc(),
      );

      // Escuchar ANTES de agregar el evento.
      // Este controller debe ser el único productor de tracking
      // individual mientras esta pantalla esté operando.
      var comenzo = false;

      final respuestaPendiente = trackingBloc.stream
          .firstWhere((state) {
            if (state.operacion != TrackingOperacion.registrarUbicacion) {
              return false;
            }

            if (state.procesando) {
              comenzo = true;
              return false;
            }

            return comenzo;
          })
          .timeout(const Duration(seconds: 45));

      trackingBloc.add(TrackingUbicacionRegistrada(request: request));

      final respuesta = await respuestaPendiente;

      if (!_sigueVigente(generacion, idRecorrido)) return;

      final recurso = respuesta.ubicacionResponse;

      if (recurso is Success<ApiResponse<RegistrarUbicacionDataModel>>) {
        if (!recurso.data.success) {
          _informar(recurso.data.message);
        } else {
          // No mostrar un SnackBar por cada posición exitosa.
          _ultimoMensaje = null;
        }
      } else if (recurso
          is ErrorData<ApiResponse<RegistrarUbicacionDataModel>>) {
        _informar(recurso.fullMessage);
      } else if (respuesta.errorInesperado != null) {
        _informar(respuesta.errorInesperado!);
      }
    } catch (_) {
      if (_sigueVigente(generacion, idRecorrido)) {
        _informar(
          'No se pudo completar el envío GPS. '
          'Se intentará una nueva muestra en el siguiente ciclo.',
        );
      }
    } finally {
      _enviando = false;
    }
  }

  bool _sigueVigente(int generacion, int idRecorrido) {
    return !_disposed &&
        !trackingBloc.isClosed &&
        !recorridoBloc.isClosed &&
        _generacion == generacion &&
        _idRecorrido == idRecorrido;
  }

  double? _finito(double? valor) {
    return valor != null && valor.isFinite ? valor : null;
  }

  double? _noNegativo(double? valor) {
    final numero = _finito(valor);
    return numero != null && numero >= 0 ? numero : null;
  }

  // UUID v4 sin agregar otra dependencia.
  String _crearUuid() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  void _informar(String mensaje) {
    if (_disposed) return;

    final ahora = DateTime.now();

    if (_ultimoMensaje == mensaje &&
        _fechaUltimoMensaje != null &&
        ahora.difference(_fechaUltimoMensaje!) < const Duration(seconds: 30)) {
      return;
    }

    _ultimoMensaje = mensaje;
    _fechaUltimoMensaje = ahora;

    onMensaje(mensaje);
  }

  // ========================================================
  // DETENER Y LIBERAR
  // ========================================================

  void detener() {
    _generacion++;
    _temporizador?.cancel();
    _temporizador = null;
    _idRecorrido = null;
  }

  void dispose() {
    if (_disposed) return;

    _disposed = true;
    detener();

    unawaited(_suscripcionRecorrido.cancel());

    // Los BLoC globales no se cierran aquí.
  }
}
