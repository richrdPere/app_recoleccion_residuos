import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// *********************************************************
// MODELO - DETALLE DE INCIDENCIA
// *********************************************************

class IncidenciaDetalleModel extends IncidenciaListadoModel {
  final List<IncidenciaArchivoModel> archivos;

  IncidenciaDetalleModel({
    required IncidenciaListadoModel incidencia,
    required List<IncidenciaArchivoModel> archivos,
  }) : archivos = List<IncidenciaArchivoModel>.unmodifiable(archivos),
       super(
         idIncidencia: incidencia.idIncidencia,
         idUsuarioReporte: incidencia.idUsuarioReporte,
         idResponsable: incidencia.idResponsable,
         idRecorrido: incidencia.idRecorrido,
         idZona: incidencia.idZona,
         idRuta: incidencia.idRuta,
         tipo: incidencia.tipo,
         prioridad: incidencia.prioridad,
         titulo: incidencia.titulo,
         descripcion: incidencia.descripcion,
         origen: incidencia.origen,
         estadoIncidencia: incidencia.estadoIncidencia,
         fechaReporte: incidencia.fechaReporte,
         fechaResolucion: incidencia.fechaResolucion,
         detalleResolucion: incidencia.detalleResolucion,
         latitud: incidencia.latitud,
         longitud: incidencia.longitud,
         precisionUbicacion: incidencia.precisionUbicacion,
         direccionReferencia: incidencia.direccionReferencia,
         estado: incidencia.estado,
         createdAt: incidencia.createdAt,
         updatedAt: incidencia.updatedAt,
         deletedAt: incidencia.deletedAt,
         reportante: incidencia.reportante,
         responsable: incidencia.responsable,
         zona: incidencia.zona,
         ruta: incidencia.ruta,
         recorrido: incidencia.recorrido,
       );

  factory IncidenciaDetalleModel.fromJson(Map<String, dynamic> json) {
    final incidencia = IncidenciaListadoModel.fromJson(json);

    final rawArchivos = json['archivos'];

    if (rawArchivos is! List) {
      throw const FormatException(
        'Los archivos de la incidencia no tienen un formato válido.',
      );
    }

    final archivos = rawArchivos.map((item) {
      if (item is! Map) {
        throw const FormatException('La evidencia no tiene un formato válido.');
      }

      return IncidenciaArchivoModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    return IncidenciaDetalleModel(incidencia: incidencia, archivos: archivos);
  }
}
