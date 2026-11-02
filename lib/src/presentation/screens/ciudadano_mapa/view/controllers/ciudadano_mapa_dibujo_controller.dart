import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import 'package:app_recoleccion_residuos/src/data/models/ciudadanos/get_domicilio_servicio_activo_model.dart';

class CiudadanoMapaDibujoController {
  final void Function(String) onError;

  CiudadanoMapaDibujoController({required this.onError});

  mb.MapboxMap? _mapa;
  mb.CircleAnnotationManager? _circulos;
  mb.PolylineAnnotationManager? _lineas;

  GetDomicilioServicioActivoDataModel? _datos;

  Future<void> _cola = Future<void>.value();

  int _version = 0;
  bool _disposed = false;

  void asociarMapa(mb.MapboxMap mapa) {
    _version++;
    _mapa = mapa;
    _circulos = null;
    _lineas = null;
  }

  bool _vigente(int version) => !_disposed && version == _version;

  Future<void> prepararAnotaciones() async {
    final mapa = _mapa;
    if (_disposed || mapa == null) return;

    final version = ++_version;

    _lineas = null;
    _circulos = null;

    try {
      final lineas = await mapa.annotations.createPolylineAnnotationManager();

      if (!_vigente(version)) return;

      final circulos = await mapa.annotations.createCircleAnnotationManager();

      if (!_vigente(version)) return;

      _lineas = lineas;
      _circulos = circulos;

      actualizar(_datos);

      final domicilio = _datos?.domicilio;

      if (domicilio != null) {
        await centrar(domicilio.latitud, domicilio.longitud);
      }
    } catch (_) {
      if (_vigente(version)) {
        onError('No se pudieron preparar los elementos del mapa.');
      }
    }
  }

  void actualizar(GetDomicilioServicioActivoDataModel? datos) {
    _datos = datos;
    final version = _version;

    _cola = _cola
        .then<void>((_) async {
          if (!_vigente(version)) return;

          final lineas = _lineas;
          final circulos = _circulos;
          final actual = _datos;

          if (lineas == null || circulos == null) return;

          await lineas.deleteAll();
          if (!_vigente(version)) return;

          await circulos.deleteAll();
          if (!_vigente(version) || actual == null) return;

          final geometria = actual.ruta?.geometriaGeojson;

          if (geometria != null) {
            await lineas.create(
              mb.PolylineAnnotationOptions(
                geometry: mb.LineString(
                  coordinates: geometria.coordinates
                      .map((p) => mb.Position(p[0], p[1]))
                      .toList(),
                ),
                lineColor: _colorRuta(actual.ruta?.color),
                lineWidth: 5,
              ),
            );
          }

          if (!_vigente(version)) return;

          final domicilio = actual.domicilio;

          if (domicilio.latitud != null && domicilio.longitud != null) {
            await circulos.create(
              mb.CircleAnnotationOptions(
                geometry: _punto(domicilio.latitud!, domicilio.longitud!),
                circleColor: 0xFF2563EB,
                circleRadius: 8,
                circleStrokeColor: 0xFFFFFFFF,
                circleStrokeWidth: 3,
              ),
            );
          }

          if (!_vigente(version)) return;

          final camion = actual.tieneServicioActivo
              ? actual.servicio?.ultimaUbicacion
              : null;

          if (camion != null) {
            await circulos.create(
              mb.CircleAnnotationOptions(
                geometry: _punto(camion.latitud, camion.longitud),
                circleColor: 0xFFEA580C,
                circleRadius: 11,
                circleStrokeColor: 0xFFFFFFFF,
                circleStrokeWidth: 3,
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

  Future<void> centrar(double? latitud, double? longitud) async {
    final mapa = _mapa;

    if (_disposed || mapa == null || latitud == null || longitud == null) {
      return;
    }

    try {
      await mapa.flyTo(
        mb.CameraOptions(center: _punto(latitud, longitud), zoom: 15),
        mb.MapAnimationOptions(duration: 700),
      );
    } catch (_) {
      if (!_disposed) {
        onError('No se pudo centrar el mapa.');
      }
    }
  }

  mb.Point _punto(double latitud, double longitud) {
    return mb.Point(coordinates: mb.Position(longitud, latitud));
  }

  int _colorRuta(String? value) {
    final hex = value?.replaceFirst('#', '');

    if (hex == null || !RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
      return 0xFF2563EB;
    }

    return int.parse('FF$hex', radix: 16);
  }

  void dispose() {
    _disposed = true;
    _version++;
    _mapa = null;
    _lineas = null;
    _circulos = null;
  }
}
