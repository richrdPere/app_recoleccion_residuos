import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// *********************************************************
// ALIAS DE RESPUESTAS
// *********************************************************

typedef IncidenciasCreacionResponse = ApiResponse<CreateIncidenciaDataModel>;

typedef IncidenciasListadoResponse = ApiResponse<IncidenciasPaginadasDataModel>;

typedef IncidenciasDetalleResponse = ApiResponse<IncidenciaDetalleModel>;

typedef IncidenciasCargaArchivosResponse =
    ApiResponse<List<IncidenciaArchivoCreadoModel>>;

typedef IncidenciasArchivosResponse =
    ApiResponse<List<IncidenciaArchivoListadoModel>>;

typedef IncidenciasArchivoResponse = ApiResponse<IncidenciaArchivoDetalleModel>;

typedef IncidenciasEliminarArchivoResponse =
    ApiResponse<DeleteIncidenciaArchivoDataModel>;

typedef IncidenciasActualizacionResponse =
    ApiResponse<UpdateIncidenciaDataModel>;

typedef IncidenciasCambioEstadoResponse =
    ApiResponse<ChangeIncidenciaEstadoDataModel>;

// *********************************************************
// ESTADO DE UNA OPERACIÓN
// *********************************************************

enum EstadoOperacionIncidencia { inicial, cargando, exito, error }

// *********************************************************
// IDENTIFICADORES DE OPERACIONES
// *********************************************************

enum OperacionIncidencias {
  creacion,
  listado,
  detalle,
  cargaArchivos,
  archivos,
  archivo,
  eliminacionArchivo,
  actualizacion,
  cambioEstado,
}

// *********************************************************
// ESTADO INDIVIDUAL DE UNA OPERACIÓN
// *********************************************************

class OperacionIncidenciaState<T> {
  final EstadoOperacionIncidencia estado;

  /// Resultado tipado del caso de uso.
  final Resource<T>? resultado;

  /// Recurso al que corresponde esta operación.
  final int? idIncidencia;
  final int? idArchivo;

  /// Identifica cada ejecución dentro del BLoC.
  final int ejecucion;

  const OperacionIncidenciaState({
    this.estado = EstadoOperacionIncidencia.inicial,
    this.resultado,
    this.idIncidencia,
    this.idArchivo,
    this.ejecucion = 0,
  });

  bool get estaInicial => estado == EstadoOperacionIncidencia.inicial;

  bool get estaCargando => estado == EstadoOperacionIncidencia.cargando;

  bool get tieneExito => estado == EstadoOperacionIncidencia.exito;

  bool get tieneError => estado == EstadoOperacionIncidencia.error;

  String? get mensajeError {
    if (!tieneError) {
      return null;
    }

    final resource = resultado;

    if (resource is ErrorData<T>) {
      return resource.message;
    }

    return 'No se pudo completar la operación.';
  }
}

// *********************************************************
// ESTADO GENERAL DE INCIDENCIAS
// *********************************************************

class IncidenciasState {
  final OperacionIncidenciaState<IncidenciasCreacionResponse> creacion;

  final OperacionIncidenciaState<IncidenciasListadoResponse> listado;

  final OperacionIncidenciaState<IncidenciasDetalleResponse> detalle;

  final OperacionIncidenciaState<IncidenciasCargaArchivosResponse>
  cargaArchivos;

  final OperacionIncidenciaState<IncidenciasArchivosResponse> archivos;

  final OperacionIncidenciaState<IncidenciasArchivoResponse> archivo;

  final OperacionIncidenciaState<IncidenciasEliminarArchivoResponse>
  eliminacionArchivo;

  final OperacionIncidenciaState<IncidenciasActualizacionResponse>
  actualizacion;

  final OperacionIncidenciaState<IncidenciasCambioEstadoResponse> cambioEstado;

  const IncidenciasState({
    this.creacion =
        const OperacionIncidenciaState<IncidenciasCreacionResponse>(),

    this.listado = const OperacionIncidenciaState<IncidenciasListadoResponse>(),

    this.detalle = const OperacionIncidenciaState<IncidenciasDetalleResponse>(),

    this.cargaArchivos =
        const OperacionIncidenciaState<IncidenciasCargaArchivosResponse>(),

    this.archivos =
        const OperacionIncidenciaState<IncidenciasArchivosResponse>(),

    this.archivo = const OperacionIncidenciaState<IncidenciasArchivoResponse>(),

    this.eliminacionArchivo =
        const OperacionIncidenciaState<IncidenciasEliminarArchivoResponse>(),

    this.actualizacion =
        const OperacionIncidenciaState<IncidenciasActualizacionResponse>(),

    this.cambioEstado =
        const OperacionIncidenciaState<IncidenciasCambioEstadoResponse>(),
  });

  IncidenciasState copyWith({
    OperacionIncidenciaState<IncidenciasCreacionResponse>? creacion,

    OperacionIncidenciaState<IncidenciasListadoResponse>? listado,

    OperacionIncidenciaState<IncidenciasDetalleResponse>? detalle,

    OperacionIncidenciaState<IncidenciasCargaArchivosResponse>? cargaArchivos,

    OperacionIncidenciaState<IncidenciasArchivosResponse>? archivos,

    OperacionIncidenciaState<IncidenciasArchivoResponse>? archivo,

    OperacionIncidenciaState<IncidenciasEliminarArchivoResponse>?
    eliminacionArchivo,

    OperacionIncidenciaState<IncidenciasActualizacionResponse>? actualizacion,

    OperacionIncidenciaState<IncidenciasCambioEstadoResponse>? cambioEstado,
  }) {
    return IncidenciasState(
      creacion: creacion ?? this.creacion,
      listado: listado ?? this.listado,
      detalle: detalle ?? this.detalle,
      cargaArchivos: cargaArchivos ?? this.cargaArchivos,
      archivos: archivos ?? this.archivos,
      archivo: archivo ?? this.archivo,
      eliminacionArchivo: eliminacionArchivo ?? this.eliminacionArchivo,
      actualizacion: actualizacion ?? this.actualizacion,
      cambioEstado: cambioEstado ?? this.cambioEstado,
    );
  }
}
