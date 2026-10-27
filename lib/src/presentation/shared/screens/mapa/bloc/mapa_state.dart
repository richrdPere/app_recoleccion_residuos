import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class MapaState {
  const MapaState();
}

class MapaInicial extends MapaState {
  const MapaInicial();
}

class MapaConfiguracionCargando extends MapaState {
  const MapaConfiguracionCargando();
}

class MapaConfiguracionDisponible extends MapaState {
  final MapaConfiguracion configuracion;

  const MapaConfiguracionDisponible({
    required this.configuracion,
  });
}

class MapaConfiguracionError extends MapaState {
  final String mensaje;

  const MapaConfiguracionError({
    required this.mensaje,
  });
}