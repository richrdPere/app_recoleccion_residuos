// *********************************************************
// REQUEST - CAMBIAR ESTADO DE INCIDENCIA
// *********************************************************

class ChangeIncidenciaEstadoRequest {
  final String estadoIncidencia;
  final String? detalleResolucion;

  const ChangeIncidenciaEstadoRequest({
    required this.estadoIncidencia,
    this.detalleResolucion,
  });

  Map<String, dynamic> toJson() {
    return {
      'estado_incidencia': estadoIncidencia,

      if (detalleResolucion != null)
        'detalle_resolucion': detalleResolucion!.trim(),
    };
  }
}

// *********************************************************
// DATA - ESTADO DE INCIDENCIA ACTUALIZADO
// *********************************************************

class ChangeIncidenciaEstadoDataModel {
  final int idIncidencia;
  final int idUsuarioReporte;
  final int? idResponsable;

  final int? idRecorrido;
  final int? idZona;
  final int? idRuta;

  final String tipo;
  final String prioridad;
  final String titulo;
  final String descripcion;

  final String origen;
  final String estadoIncidencia;

  final String fechaReporte;
  final String? fechaResolucion;
  final String? detalleResolucion;

  final double? latitud;
  final double? longitud;
  final double? precisionUbicacion;

  final String? direccionReferencia;

  final bool estado;

  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  final ChangeIncidenciaEstadoUsuarioModel? reportante;
  final ChangeIncidenciaEstadoUsuarioModel? responsable;
  final ChangeIncidenciaEstadoZonaModel? zona;
  final ChangeIncidenciaEstadoRutaModel? ruta;
  final ChangeIncidenciaEstadoRecorridoModel? recorrido;

  final List<ChangeIncidenciaEstadoArchivoModel> archivos;

  ChangeIncidenciaEstadoDataModel.fromJson(Map<String, dynamic> json)
    : idIncidencia = _readInt(json['id_incidencia']),
      idUsuarioReporte = _readInt(json['id_usuario_reporte']),
      idResponsable = _readNullableInt(json['id_responsable']),
      idRecorrido = _readNullableInt(json['id_recorrido']),
      idZona = _readNullableInt(json['id_zona']),
      idRuta = _readNullableInt(json['id_ruta']),
      tipo = json['tipo'] as String,
      prioridad = json['prioridad'] as String,
      titulo = json['titulo'] as String,
      descripcion = json['descripcion'] as String,
      origen = json['origen'] as String,
      estadoIncidencia = json['estado_incidencia'] as String,
      fechaReporte = json['fecha_reporte'] as String,
      fechaResolucion = json['fecha_resolucion'] as String?,
      detalleResolucion = json['detalle_resolucion'] as String?,
      latitud = _readNullableDouble(json['latitud']),
      longitud = _readNullableDouble(json['longitud']),
      precisionUbicacion = _readNullableDouble(json['precision_ubicacion']),
      direccionReferencia = json['direccion_referencia'] as String?,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?,
      reportante = _readOptional(
        json['reportante'],
        ChangeIncidenciaEstadoUsuarioModel.fromJson,
      ),
      responsable = _readOptional(
        json['responsable'],
        ChangeIncidenciaEstadoUsuarioModel.fromJson,
      ),
      zona = _readOptional(
        json['zona'],
        ChangeIncidenciaEstadoZonaModel.fromJson,
      ),
      ruta = _readOptional(
        json['ruta'],
        ChangeIncidenciaEstadoRutaModel.fromJson,
      ),
      recorrido = _readOptional(
        json['recorrido'],
        ChangeIncidenciaEstadoRecorridoModel.fromJson,
      ),
      archivos = List<ChangeIncidenciaEstadoArchivoModel>.unmodifiable(
        _readList(json['archivos']).map(
          (item) => ChangeIncidenciaEstadoArchivoModel.fromJson(_readMap(item)),
        ),
      );
}

// *********************************************************
// USUARIO
// *********************************************************

class ChangeIncidenciaEstadoUsuarioModel {
  final int idUsuario;
  final String username;

  ChangeIncidenciaEstadoUsuarioModel.fromJson(Map<String, dynamic> json)
    : idUsuario = _readInt(json['id_usuario']),
      username = json['username'] as String;
}

// *********************************************************
// ZONA
// *********************************************************

class ChangeIncidenciaEstadoZonaModel {
  final int idZona;
  final String codigo;
  final String nombre;

  ChangeIncidenciaEstadoZonaModel.fromJson(Map<String, dynamic> json)
    : idZona = _readInt(json['id_zona']),
      codigo = json['codigo'] as String,
      nombre = json['nombre'] as String;
}

// *********************************************************
// RUTA
// *********************************************************

class ChangeIncidenciaEstadoRutaModel {
  final int idRuta;
  final String codigo;
  final String nombre;

  ChangeIncidenciaEstadoRutaModel.fromJson(Map<String, dynamic> json)
    : idRuta = _readInt(json['id_ruta']),
      codigo = json['codigo'] as String,
      nombre = json['nombre'] as String;
}

// *********************************************************
// RECORRIDO
// *********************************************************

class ChangeIncidenciaEstadoRecorridoModel {
  final int idRecorrido;
  final String estadoRecorrido;

  ChangeIncidenciaEstadoRecorridoModel.fromJson(Map<String, dynamic> json)
    : idRecorrido = _readInt(json['id_recorrido']),
      estadoRecorrido = json['estado_recorrido'] as String;
}

// *********************************************************
// ARCHIVO
// *********************************************************

class ChangeIncidenciaEstadoArchivoModel {
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
  final String? updatedAt;
  final String? deletedAt;

  ChangeIncidenciaEstadoArchivoModel.fromJson(Map<String, dynamic> json)
    : idIncidenciaArchivo = _readInt(json['id_incidencia_archivo']),
      idIncidencia = _readInt(json['id_incidencia']),
      idUsuarioCarga = _readInt(json['id_usuario_carga']),
      tipoArchivo = json['tipo_archivo'] as String,
      nombreOriginal = json['nombre_original'] as String,
      mimeType = json['mime_type'] as String,
      tamanioBytes = _readInt(json['tamanio_bytes']),
      descripcion = json['descripcion'] as String?,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String?,
      deletedAt = json['deleted_at'] as String?;
}

// *********************************************************
// UTILIDADES PRIVADAS DE PARSEO
// *********************************************************

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw const FormatException('Se esperaba un objeto JSON.');
}

List<dynamic> _readList(dynamic value) {
  if (value is List) {
    return value;
  }

  throw const FormatException('Se esperaba una lista de archivos.');
}

T? _readOptional<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  return value == null ? null : parser(_readMap(value));
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

int? _readNullableInt(dynamic value) {
  return value == null ? null : _readInt(value);
}

double? _readNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  final parsed = value is num
      ? value.toDouble()
      : value is String
      ? double.tryParse(value.trim())
      : null;

  if (parsed == null || !parsed.isFinite) {
    throw const FormatException('Se esperaba un decimal válido.');
  }

  return parsed;
}
