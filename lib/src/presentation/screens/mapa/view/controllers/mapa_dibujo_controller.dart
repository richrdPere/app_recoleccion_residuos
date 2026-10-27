import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class MapaDibujoController {
  final void Function(String mensaje) onError;

  MapaDibujoController({required this.onError});

  mb.MapboxMap? _mapa;
  mb.CircleAnnotationManager? _circulos;
  mb.PolylineAnnotationManager? _lineas;

  UbicacionEntity? _ubicacion;
  DireccionGeograficaEntity? _destino;
  RutaCalculadaEntity? _ruta;

  Future<void> _colaDibujo = Future<void>.value();

  int _versionEstilo = 0;
  bool _disposed = false;

  // *********************************************************
  // 1. ASOCIAR MAPA
  // *********************************************************

  void asociarMapa(mb.MapboxMap mapa) {
    if (_disposed) return;

    _versionEstilo++;

    _mapa = mapa;
    _circulos = null;
    _lineas = null;
  }

  // *********************************************************
  // 2. PREPARAR ANOTACIONES
  // *********************************************************

  Future<void> prepararAnotaciones() async {
    final mapa = _mapa;

    if (_disposed || mapa == null) return;

    final version = ++_versionEstilo;

    _circulos = null;
    _lineas = null;

    try {
      final lineas = await mapa.annotations.createPolylineAnnotationManager();

      if (!_vigente(version)) return;

      final circulos = await mapa.annotations.createCircleAnnotationManager();

      if (!_vigente(version)) return;

      _lineas = lineas;
      _circulos = circulos;

      _programarDibujo();
    } catch (_) {
      if (_vigente(version)) {
        onError('No se pudieron preparar los elementos del mapa.');
      }
    }
  }

  // *********************************************************
  // 3. ACTUALIZAR DATOS VISUALES
  // *********************************************************

  void actualizar({
    required UbicacionEntity? ubicacion,
    required DireccionGeograficaEntity? destino,
    required RutaCalculadaEntity? ruta,
  }) {
    if (_disposed) return;

    _ubicacion = ubicacion;
    _destino = destino;
    _ruta = ruta;

    _programarDibujo();
  }

  // *********************************************************
  // 4. DIBUJAR SIN SUPERPONER OPERACIONES
  // *********************************************************

  void _programarDibujo() {
    final version = _versionEstilo;

    _colaDibujo = _colaDibujo
        .then<void>((_) async {
          if (!_vigente(version)) return;

          final circulos = _circulos;
          final lineas = _lineas;

          if (circulos == null || lineas == null) return;

          await circulos.deleteAll();

          if (!_vigente(version)) return;

          await lineas.deleteAll();

          if (!_vigente(version)) return;

          final ubicacion = _ubicacion;
          final destino = _destino;
          final ruta = _ruta;

          if (ubicacion != null) {
            await circulos.create(
              mb.CircleAnnotationOptions(
                geometry: _punto(ubicacion.coordenada),
                circleColor: 0xFF1565C0,
                circleRadius: 8,
                circleStrokeColor: 0xFFFFFFFF,
                circleStrokeWidth: 2,
              ),
            );
          }

          if (!_vigente(version)) return;

          if (destino != null) {
            await circulos.create(
              mb.CircleAnnotationOptions(
                geometry: _punto(destino.coordenada),
                circleColor: 0xFFD32F2F,
                circleRadius: 8,
                circleStrokeColor: 0xFFFFFFFF,
                circleStrokeWidth: 2,
              ),
            );
          }

          if (!_vigente(version)) return;

          if (ruta != null && ruta.geometria.length >= 2) {
            await lineas.create(
              mb.PolylineAnnotationOptions(
                geometry: mb.LineString(
                  coordinates: ruta.geometria
                      .map(
                        (punto) => mb.Position(punto.longitud, punto.latitud),
                      )
                      .toList(),
                ),
                lineColor: 0xFF1565C0,
                lineWidth: 5,
              ),
            );
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          if (_vigente(version)) {
            onError('No se pudieron actualizar los elementos del mapa.');
          }
        });
  }

  // *********************************************************
  // 5. CENTRAR CÁMARA
  // *********************************************************

  Future<void> centrar(CoordenadaEntity coordenada, {double zoom = 15}) async {
    final mapa = _mapa;
    final version = _versionEstilo;

    if (_disposed || mapa == null) return;

    try {
      await mapa.flyTo(
        mb.CameraOptions(center: _punto(coordenada), zoom: zoom),
        mb.MapAnimationOptions(duration: 800),
      );
    } catch (_) {
      if (_vigente(version)) {
        onError('No se pudo centrar el mapa.');
      }
    }
  }

  // *********************************************************
  // UTILIDADES
  // *********************************************************

  mb.Point _punto(CoordenadaEntity coordenada) {
    return mb.Point(
      coordinates: mb.Position(coordenada.longitud, coordenada.latitud),
    );
  }

  bool _vigente(int version) {
    return !_disposed && version == _versionEstilo;
  }

  void dispose() {
    _disposed = true;
    _versionEstilo++;

    _mapa = null;
    _circulos = null;
    _lineas = null;

    // El MapWidget conserva la responsabilidad de destruir
    // el mapa nativo y sus recursos asociados.
  }
}
