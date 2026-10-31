// *********************************************************
// REQUEST - AGREGAR ARCHIVOS
// *********************************************************

class AgregarIncidenciaArchivosRequest {
  final List<String> archivosPaths;

  /// Descripción común para los archivos de esta solicitud.
  final String? descripcion;

  const AgregarIncidenciaArchivosRequest({
    required this.archivosPaths,
    this.descripcion,
  });

  Map<String, String> toFields() {
    final texto = descripcion?.trim();

    return {if (texto != null && texto.isNotEmpty) 'descripcion': texto};
  }
}

// *********************************************************
// DATA - ARCHIVO REGISTRADO
// *********************************************************

class IncidenciaArchivoCreadoModel {
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

  const IncidenciaArchivoCreadoModel({
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
  });

  factory IncidenciaArchivoCreadoModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaArchivoCreadoModel(
      idIncidenciaArchivo: _readInt(json['id_incidencia_archivo']),
      idIncidencia: _readInt(json['id_incidencia']),
      idUsuarioCarga: _readInt(json['id_usuario_carga']),
      tipoArchivo: json['tipo_archivo'] as String,
      nombreOriginal: json['nombre_original'] as String,
      mimeType: json['mime_type'] as String,
      tamanioBytes: _readInt(json['tamanio_bytes']),
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    final parsed = int.tryParse(value.trim());

    if (parsed != null) {
      return parsed;
    }
  }

  throw const FormatException('Se esperaba un entero válido.');
}
