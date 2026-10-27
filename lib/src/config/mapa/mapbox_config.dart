import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxConfig {
  MapboxConfig._();

  static void inicializar(String accessToken) {
    final token = accessToken.trim();

    if (token.isEmpty) {
      throw StateError('El token de Mapbox no está configurado.');
    }

    if (!token.startsWith('pk.')) {
      throw StateError('Mapbox requiere un token público que comience con pk.');
    }

    MapboxOptions.setAccessToken(token);
  }
}

// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class MapboxConfig {
//   MapboxConfig._();

//   static const String _accessToken = String.fromEnvironment(
//     'MAPBOX_ACCESS_TOKEN',
//   );

//   static void inicializar() {
//     final token = _accessToken.trim();

//     if (token.isEmpty) {
//       throw StateError(
//         'Falta MAPBOX_ACCESS_TOKEN. '
//         'Ejecuta Flutter utilizando --dart-define.',
//       );
//     }

//     if (!token.startsWith('pk.')) {
//       throw StateError(
//         'MAPBOX_ACCESS_TOKEN debe ser un token público de Mapbox.',
//       );
//     }

//     MapboxOptions.setAccessToken(token);
//   }
// }
