// *********************************************************
// MODELO - ARCHIVO DEL LISTADO POR INCIDENCIA
// *********************************************************

class IncidenciaArchivoListadoModel {
  final int idIncidenciaArchivo;
  final int idIncidencia;
  final int idUsuarioCarga;

  final String tipoArchivo;
  final String nombreOriginal;
  final String mimeType;

  final int tamanioBytes;
  final String? descripcion;

  final bool estado;

  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const IncidenciaArchivoListadoModel({
    required this.idIncidenciaArchivo,
    required this.idIncidencia,
    required this.idUsuarioCarga,
    required this.tipoArchivo,
    required this.nombreOriginal,
    required this.mimeType,
    required this.tamanioBytes,
    required this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory IncidenciaArchivoListadoModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaArchivoListadoModel(
      idIncidenciaArchivo: _readInt(
        json['id_incidencia_archivo'],
        'id_incidencia_archivo',
      ),
      idIncidencia: _readInt(json['id_incidencia'], 'id_incidencia'),
      idUsuarioCarga: _readInt(json['id_usuario_carga'], 'id_usuario_carga'),
      tipoArchivo: json['tipo_archivo'] as String,
      nombreOriginal: json['nombre_original'] as String,
      mimeType: json['mime_type'] as String,
      tamanioBytes: _readInt(json['tamanio_bytes'], 'tamanio_bytes'),
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}

// *********************************************************
// UTILIDAD PRIVADA DE PARSEO
// Admite identificadores y tamaños como números o cadenas.
// *********************************************************

int _readInt(dynamic value, String field) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    final parsed = int.tryParse(value.trim());

    if (parsed != null) {
      return parsed;
    }
  }

  throw FormatException('El campo "$field" debe ser un entero válido.');
}
