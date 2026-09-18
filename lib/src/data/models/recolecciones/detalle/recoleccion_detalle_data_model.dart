import 'package:app_recoleccion_residuos/src/data/models/recolecciones/evidencias/recoleccion_evidencia_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/puntos_recorrido/punto_recorrido_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion/registrar_recoleccion_req.dart';

// *********************************************************
// CONVERSIÓN DE DECIMALES
// *********************************************************
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();

  return double.parse(value as String);
}

// *********************************************************
// DETALLE DE RECOLECCIÓN
// Hereda datos de registro y anulación.
// *********************************************************
class RecoleccionDetalleDataModel extends PuntoRecorridoRecoleccionModel {
  final RecoleccionRecorridoModel recorrido;
  final RecoleccionPuntoRutaModel puntoRuta;
  final RecoleccionUsuarioRegistroModel usuarioRegistro;
  final RecoleccionUsuarioAnulacionModel? usuarioAnulacion;
  final List<RecoleccionDetalleEvidenciaModel> evidencias;

  RecoleccionDetalleDataModel.fromJson(Map<String, dynamic> json)
    : recorrido = RecoleccionRecorridoModel.fromJson(
        Map<String, dynamic>.from(json['recorrido'] as Map),
      ),
      puntoRuta = RecoleccionPuntoRutaModel.fromJson(
        Map<String, dynamic>.from(json['punto_ruta'] as Map),
      ),
      usuarioRegistro = RecoleccionUsuarioRegistroModel.fromJson(
        Map<String, dynamic>.from(json['usuario_registro'] as Map),
      ),
      usuarioAnulacion = json['usuario_anulacion'] == null
          ? null
          : RecoleccionUsuarioAnulacionModel.fromJson(
              Map<String, dynamic>.from(json['usuario_anulacion'] as Map),
            ),
      evidencias = (json['evidencias'] as List)
          .map(
            (item) => RecoleccionDetalleEvidenciaModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      super.fromJson(json);
}

// *********************************************************
// RECORRIDO SIN RELACIONES
// *********************************************************
class RecoleccionRecorridoModel {
  final int idRecorrido;
  final int idProgramacion;
  final int idUsuarioInicio;
  final int? idUsuarioFinalizacion;

  final String estadoRecorrido;
  final String fechaHoraInicio;
  final String? fechaHoraFinalizacion;

  final double? latitudInicio;
  final double? longitudInicio;
  final double? precisionInicio;

  final double? latitudFinalizacion;
  final double? longitudFinalizacion;
  final double? precisionFinalizacion;

  final double? kilometrajeInicio;
  final double? kilometrajeFinal;
  final double? distanciaRecorridaMetros;
  final int? duracionSegundos;

  final String? observacionInicio;
  final String? observacionFinalizacion;
  final String? motivoCancelacion;

  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  RecoleccionRecorridoModel.fromJson(Map<String, dynamic> json)
    : idRecorrido = (json['id_recorrido'] as num).toInt(),
      idProgramacion = (json['id_programacion'] as num).toInt(),
      idUsuarioInicio = (json['id_usuario_inicio'] as num).toInt(),
      idUsuarioFinalizacion = (json['id_usuario_finalizacion'] as num?)
          ?.toInt(),
      estadoRecorrido = json['estado_recorrido'] as String,
      fechaHoraInicio = json['fecha_hora_inicio'] as String,
      fechaHoraFinalizacion = json['fecha_hora_finalizacion'] as String?,
      latitudInicio = _toDouble(json['latitud_inicio']),
      longitudInicio = _toDouble(json['longitud_inicio']),
      precisionInicio = _toDouble(json['precision_inicio']),
      latitudFinalizacion = _toDouble(json['latitud_finalizacion']),
      longitudFinalizacion = _toDouble(json['longitud_finalizacion']),
      precisionFinalizacion = _toDouble(json['precision_finalizacion']),
      kilometrajeInicio = _toDouble(json['kilometraje_inicio']),
      kilometrajeFinal = _toDouble(json['kilometraje_final']),
      distanciaRecorridaMetros = _toDouble(json['distancia_recorrida_metros']),
      duracionSegundos = (json['duracion_segundos'] as num?)?.toInt(),
      observacionInicio = json['observacion_inicio'] as String?,
      observacionFinalizacion = json['observacion_finalizacion'] as String?,
      motivoCancelacion = json['motivo_cancelacion'] as String?,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?;
}

// *********************************************************
// USUARIOS
// *********************************************************
class RecoleccionUsuarioAnulacionModel {
  final int idUsuario;
  final String username;

  RecoleccionUsuarioAnulacionModel.fromJson(Map<String, dynamic> json)
    : idUsuario = (json['id_usuario'] as num).toInt(),
      username = json['username'] as String;
}

class RecoleccionUsuarioRegistroModel extends RecoleccionUsuarioAnulacionModel {
  final String emailAcceso;

  RecoleccionUsuarioRegistroModel.fromJson(Map<String, dynamic> json)
    : emailAcceso = json['email_acceso'] as String,
      super.fromJson(json);
}

// *********************************************************
// EVIDENCIA SIN USUARIO ANIDADO
// *********************************************************
class RecoleccionDetalleEvidenciaModel extends RecoleccionEvidenciaDataModel {
  final String? urlArchivo;
  final String? hashSha256;
  final String? motivoAnulacion;
  final String? fechaAnulacion;
  final int? idUsuarioAnulacion;

  RecoleccionDetalleEvidenciaModel.fromJson(Map<String, dynamic> json)
    : urlArchivo = json['url_archivo'] as String?,
      hashSha256 = json['hash_sha256'] as String?,
      motivoAnulacion = json['motivo_anulacion'] as String?,
      fechaAnulacion = json['fecha_anulacion'] as String?,
      idUsuarioAnulacion = (json['id_usuario_anulacion'] as num?)?.toInt(),
      super.fromJson(json);
}
