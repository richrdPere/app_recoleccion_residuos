import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class MapaRepositoryImpl implements MapaRepository {
  MapaRepositoryImpl({required String accessToken}) {
    final token = accessToken.trim();

    if (token.isEmpty) {
      throw StateError('El token de Mapbox no está configurado.');
    }

    if (!token.startsWith('pk.')) {
      throw StateError('Mapbox requiere un token público que comience con pk.');
    }

    MapboxOptions.setAccessToken(token);
  }

  @override
  MapaConfiguracion getConfiguracionInicial() {
    return const MapaConfiguracion(
      // Centro aproximado de Calca, Cusco.
      latitud: -13.3214,
      longitud: -71.9556,
      zoom: 14,
      inclinacion: 0,
      orientacion: 0,
      estiloUri: MapboxStyles.MAPBOX_STREETS,
    );
  }
}
