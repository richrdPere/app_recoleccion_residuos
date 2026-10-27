import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class GeocodingUseCases {
  BuscarDireccionUC buscarDireccion;
  ObtenerDireccionUC obtenerDireccion;

  GeocodingUseCases({
    required this.buscarDireccion,
    required this.obtenerDireccion,
  });
}
