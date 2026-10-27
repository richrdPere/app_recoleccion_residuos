import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:app_recoleccion_residuos/src/data/models/mapa/mapa_configuracion.dart';

class MapaBase extends StatelessWidget {
  final MapaConfiguracion configuracion;
  final void Function(MapboxMap mapboxMap)? onMapCreated;
  final VoidCallback? onStyleLoaded;

  const MapaBase({
    super.key,
    required this.configuracion,
    this.onMapCreated,
    this.onStyleLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: configuracion.estiloUri,
      viewport: CameraViewportState(
        center: Point(
          coordinates: Position(configuracion.longitud, configuracion.latitud),
        ),
        zoom: configuracion.zoom,
        pitch: configuracion.inclinacion,
        bearing: configuracion.orientacion,
      ),
      onMapCreated: onMapCreated,
      onStyleLoadedListener: (_) {
        onStyleLoaded?.call();
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:app_recoleccion_residuos/src/data/models/mapa/mapa_configuracion.dart';

// class MapaBase extends StatelessWidget {
//   final MapaConfiguracion configuracion;
//   final void Function(MapboxMap mapboxMap)? onMapCreated;

//   const MapaBase({super.key, required this.configuracion, this.onMapCreated});

//   @override
//   Widget build(BuildContext context) {
//     return MapWidget(
//       styleUri: configuracion.estiloUri,
//       viewport: CameraViewportState(
//         center: Point(
//           coordinates: Position(configuracion.longitud, configuracion.latitud),
//         ),
//         zoom: configuracion.zoom,
//         pitch: configuracion.inclinacion,
//         bearing: configuracion.orientacion,
//       ),
//       onMapCreated: onMapCreated,
//     );
//   }
// }
