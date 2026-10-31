// *********************************************************
// DATA - ELIMINAR ARCHIVO DE INCIDENCIA
// *********************************************************

class DeleteIncidenciaArchivoDataModel {
  final int idIncidencia;
  final int idIncidenciaArchivo;
  final bool eliminado;

  const DeleteIncidenciaArchivoDataModel({
    required this.idIncidencia,
    required this.idIncidenciaArchivo,
    required this.eliminado,
  });

  factory DeleteIncidenciaArchivoDataModel.fromJson(Map<String, dynamic> json) {
    return DeleteIncidenciaArchivoDataModel(
      idIncidencia: _readInt(json['id_incidencia'], 'id_incidencia'),
      idIncidenciaArchivo: _readInt(
        json['id_incidencia_archivo'],
        'id_incidencia_archivo',
      ),
      eliminado: json['eliminado'] as bool,
    );
  }
}

// *********************************************************
// UTILIDAD PRIVADA DE PARSEO
// El backend devuelve los identificadores como cadenas.
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
