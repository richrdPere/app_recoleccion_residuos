import 'package:app_recoleccion_residuos/src/data/models/recorrido/datos/recorrido_data_model.dart';

// *********************************************************
// CONVERSIÓN DE DECIMALES
// *********************************************************
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();

  return double.parse(value.toString());
}

// *********************************************************
// DATA PAGINADA
// *********************************************************
class MisRecorridosDataModel {
  final List<MiRecorridoItemModel> items;
  final RecorridosPaginationModel pagination;

  MisRecorridosDataModel.fromJson(Map<String, dynamic> json)
    : items = (json['items'] as List)
          .map(
            (item) => MiRecorridoItemModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      pagination = RecorridosPaginationModel.fromJson(
        Map<String, dynamic>.from(json['pagination'] as Map),
      );
}

// *********************************************************
// PAGINACIÓN
// *********************************************************
class RecorridosPaginationModel {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int perPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  RecorridosPaginationModel.fromJson(Map<String, dynamic> json)
    : totalItems = (json['total_items'] as num).toInt(),
      totalPages = (json['total_pages'] as num).toInt(),
      currentPage = (json['current_page'] as num).toInt(),
      perPage = (json['per_page'] as num).toInt(),
      hasNextPage = json['has_next_page'] as bool,
      hasPreviousPage = json['has_previous_page'] as bool;
}

// *********************************************************
// ITEM DEL LISTADO
// *********************************************************
class MiRecorridoItemModel {
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

  final MiRecorridoProgramacionModel programacion;
  final MiRecorridoAsignacionModel miAsignacion;

  MiRecorridoItemModel.fromJson(Map<String, dynamic> json)
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
      deletedAt = json['deleted_at'] as String?,
      programacion = MiRecorridoProgramacionModel.fromJson(
        Map<String, dynamic>.from(json['programacion'] as Map),
      ),
      miAsignacion = MiRecorridoAsignacionModel.fromJson(
        Map<String, dynamic>.from(json['mi_asignacion'] as Map),
      );
}

// *********************************************************
// PROGRAMACIÓN CON RUTA, VERSIÓN Y VEHÍCULO
// Hereda los campos generales del modelo existente.
// *********************************************************
class MiRecorridoProgramacionModel extends RecorridoProgramacionModel {
  final MiRecorridoRutaModel ruta;
  final MiRecorridoVersionRutaModel versionRuta;
  final MiRecorridoVehiculoModel vehiculo;

  MiRecorridoProgramacionModel.fromJson(Map<String, dynamic> json)
    : ruta = MiRecorridoRutaModel.fromJson(
        Map<String, dynamic>.from(json['ruta'] as Map),
      ),
      versionRuta = MiRecorridoVersionRutaModel.fromJson(
        Map<String, dynamic>.from(json['version_ruta'] as Map),
      ),
      vehiculo = MiRecorridoVehiculoModel.fromJson(
        Map<String, dynamic>.from(json['vehiculo'] as Map),
      ),
      super.fromJson(json);
}

// *********************************************************
// RUTA
// *********************************************************
class MiRecorridoRutaModel {
  final int idRuta;
  final int idZona;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String? color;
  final String estadoRuta;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  MiRecorridoRutaModel.fromJson(Map<String, dynamic> json)
    : idRuta = (json['id_ruta'] as num).toInt(),
      idZona = (json['id_zona'] as num).toInt(),
      codigo = json['codigo'] as String,
      nombre = json['nombre'] as String,
      descripcion = json['descripcion'] as String?,
      color = json['color'] as String?,
      estadoRuta = json['estado_ruta'] as String,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?;
}

// *********************************************************
// VERSIÓN DE RUTA
// *********************************************************
class MiRecorridoVersionRutaModel {
  final int idRutaVersion;
  final int idRuta;
  final int numeroVersion;
  final RecorridoLineStringModel? geometriaGeojson;
  final double? distanciaEstimadaKm;
  final int? duracionEstimadaMin;
  final String fechaVigenciaDesde;
  final String? fechaVigenciaHasta;
  final bool vigente;
  final String? observacion;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  MiRecorridoVersionRutaModel.fromJson(Map<String, dynamic> json)
    : idRutaVersion = (json['id_ruta_version'] as num).toInt(),
      idRuta = (json['id_ruta'] as num).toInt(),
      numeroVersion = (json['numero_version'] as num).toInt(),
      geometriaGeojson = json['geometria_geojson'] == null
          ? null
          : RecorridoLineStringModel.fromJson(
              Map<String, dynamic>.from(json['geometria_geojson'] as Map),
            ),
      distanciaEstimadaKm = _toDouble(json['distancia_estimada_km']),
      duracionEstimadaMin = (json['duracion_estimada_min'] as num?)?.toInt(),
      fechaVigenciaDesde = json['fecha_vigencia_desde'] as String,
      fechaVigenciaHasta = json['fecha_vigencia_hasta'] as String?,
      vigente = json['vigente'] as bool,
      observacion = json['observacion'] as String?,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?;
}

// *********************************************************
// GEOMETRÍA LINESTRING
// Cada posición conserva el orden: [longitud, latitud].
// *********************************************************
class RecorridoLineStringModel {
  final String type;
  final List<List<double>> coordinates;

  RecorridoLineStringModel.fromJson(Map<String, dynamic> json)
    : type = json['type'] as String,
      coordinates = (json['coordinates'] as List)
          .map(
            (position) => (position as List)
                .map((value) => (value as num).toDouble())
                .toList(),
          )
          .toList() {
    if (type != 'LineString') {
      throw const FormatException(
        'La geometría de la ruta debe ser LineString.',
      );
    }
  }
}

// *********************************************************
// VEHÍCULO
// *********************************************************
class MiRecorridoVehiculoModel {
  final int idVehiculo;
  final String codigo;
  final String placa;
  final String? marca;
  final String? modelo;
  final int? anio;
  final String? color;
  final String tipoVehiculo;
  final double? capacidadMaxima;
  final String unidadCapacidad;
  final double? kilometraje;
  final String estadoOperativo;
  final String? observacion;
  final String? fotoUrl;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  MiRecorridoVehiculoModel.fromJson(Map<String, dynamic> json)
    : idVehiculo = (json['id_vehiculo'] as num).toInt(),
      codigo = json['codigo'] as String,
      placa = json['placa'] as String,
      marca = json['marca'] as String?,
      modelo = json['modelo'] as String?,
      anio = (json['anio'] as num?)?.toInt(),
      color = json['color'] as String?,
      tipoVehiculo = json['tipo_vehiculo'] as String,
      capacidadMaxima = _toDouble(json['capacidad_maxima']),
      unidadCapacidad = json['unidad_capacidad'] as String,
      kilometraje = _toDouble(json['kilometraje']),
      estadoOperativo = json['estado_operativo'] as String,
      observacion = json['observacion'] as String?,
      fotoUrl = json['foto_url'] as String?,
      estado = json['estado'] as bool,
      createdAt = json['created_at'] as String,
      updatedAt = json['updated_at'] as String,
      deletedAt = json['deleted_at'] as String?;
}

// *********************************************************
// ASIGNACIÓN DEL USUARIO AUTENTICADO
// *********************************************************
class MiRecorridoAsignacionModel {
  final int idProgramacion;
  final String funcion;
  final bool esPrincipal;
  final String estadoAsignacion;

  MiRecorridoAsignacionModel.fromJson(Map<String, dynamic> json)
    : idProgramacion = (json['id_programacion'] as num).toInt(),
      funcion = json['funcion'] as String,
      esPrincipal = json['es_principal'] as bool,
      estadoAsignacion = json['estado_asignacion'] as String;
}
