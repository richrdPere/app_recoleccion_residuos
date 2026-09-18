class RecoleccionEvidenciaDataModel {
  final int idEvidencia;
  final int idRecoleccion;
  final int idUsuario;

  final String tipoEvidencia;
  final String nombreOriginal;
  final String nombreAlmacenado;
  final String rutaArchivo;
  final String mimeType;
  final String? extension;
  final int tamanoBytes;

  final String? descripcion;
  final String? fechaCaptura;
  final String estadoEvidencia;

  final String createdAt;
  final String updatedAt;

  RecoleccionEvidenciaDataModel.fromJson(Map<String, dynamic> json)
    : idEvidencia = (json['id_evidencia'] as num).toInt(),
      idRecoleccion = (json['id_recoleccion'] as num).toInt(),
      idUsuario = (json['id_usuario'] as num).toInt(),
      tipoEvidencia = json['tipo_evidencia'] as String,
      nombreOriginal = json['nombre_original'] as String,
      nombreAlmacenado = json['nombre_almacenado'] as String,
      rutaArchivo = json['ruta_archivo'] as String,
      mimeType = json['mime_type'] as String,
      extension = json['extension'] as String?,
      tamanoBytes = (json['tamano_bytes'] as num).toInt(),
      descripcion = json['descripcion'] as String?,
      fechaCaptura = json['fecha_captura'] as String?,
      estadoEvidencia = json['estado_evidencia'] as String,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String;
}
