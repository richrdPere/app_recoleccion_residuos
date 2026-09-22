import 'package:app_recoleccion_residuos/src/data/models/tracking/registrar_ubicacion/tracking_posicion_model.dart';

class RegistrarUbicacionDataModel {
  final TrackingPosicionModel posicion;
  final bool duplicada;
  final bool ultimaUbicacionActualizada;

  RegistrarUbicacionDataModel.fromJson(Map<String, dynamic> json)
    : posicion = TrackingPosicionModel.fromJson(
        Map<String, dynamic>.from(json['posicion'] as Map),
      ),
      duplicada = json['duplicada'] as bool,
      ultimaUbicacionActualizada = json['ultima_ubicacion_actualizada'] as bool;
}
