import 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion/registrar_recoleccion_req.dart';

// *********************************************************
// PUNTO CON ESTADO DE ATENCIÓN
// *********************************************************

class PuntoRecorridoDataModel extends RecoleccionPuntoRutaModel {
  final String estadoAtencion;
  final PuntoRecorridoRecoleccionModel? recoleccion;

  PuntoRecorridoDataModel.fromJson(Map<String, dynamic> json)
    : estadoAtencion = json['estado_atencion'] as String,
      recoleccion = json['recoleccion'] == null
          ? null
          : PuntoRecorridoRecoleccionModel.fromJson(
              Map<String, dynamic>.from(json['recoleccion'] as Map),
            ),
      super.fromJson(json);

  bool get atendido => estadoAtencion == 'ATENDIDO';

  bool get pendiente => estadoAtencion == 'PENDIENTE';
}

// *********************************************************
// RECOLECCIÓN CON DATOS DE ANULACIÓN
// *********************************************************
class PuntoRecorridoRecoleccionModel extends RecoleccionDataModel {
  final String? motivoAnulacion;
  final String? fechaAnulacion;
  final int? idUsuarioAnulacion;

  PuntoRecorridoRecoleccionModel.fromJson(Map<String, dynamic> json)
    : motivoAnulacion = json['motivo_anulacion'] as String?,
      fechaAnulacion = json['fecha_anulacion'] as String?,
      idUsuarioAnulacion = (json['id_usuario_anulacion'] as num?)?.toInt(),
      super.fromJson(json);
}
