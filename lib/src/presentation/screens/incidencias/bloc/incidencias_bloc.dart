import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Use cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'incidencias_event.dart';
import 'incidencias_state.dart';

class IncidenciasBloc extends Bloc<IncidenciasEvent, IncidenciasState> {
  final IncidenciasUseCases incidenciasUseCases;

  // Controla cuál es la solicitud vigente de cada operación.
  final Map<OperacionIncidencias, int> _versiones = {};

  int _secuencia = 0;

  IncidenciasBloc(this.incidenciasUseCases) : super(const IncidenciasState()) {
    on<CrearIncidencia>(_onCrearIncidencia);

    on<ObtenerIncidenciasPaginadas>(_onObtenerIncidenciasPaginadas);

    on<ObtenerIncidenciaDetalle>(_onObtenerIncidenciaDetalle);

    on<AgregarArchivosIncidencia>(_onAgregarArchivosIncidencia);

    on<ObtenerArchivosIncidencia>(_onObtenerArchivosIncidencia);

    on<ObtenerArchivoIncidencia>(_onObtenerArchivoIncidencia);

    on<EliminarArchivoIncidencia>(_onEliminarArchivoIncidencia);

    on<ActualizarIncidencia>(_onActualizarIncidencia);

    on<CambiarEstadoIncidencia>(_onCambiarEstadoIncidencia);
  }

  // *********************************************************
  // 1. CREAR INCIDENCIA
  // *********************************************************

  Future<void> _onCrearIncidencia(
    CrearIncidencia event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasCreacionResponse>(
      emit: emit,
      operacion: OperacionIncidencias.creacion,
      actual: state.creacion,
      bloquearDuplicados: true,
      mensajeError: 'Ocurrió un error al crear la incidencia.',
      ejecutar: () =>
          incidenciasUseCases.createIncidencia.run(request: event.request),
      actualizar: (estado, resultado) => estado.copyWith(creacion: resultado),
    );
  }

  // *********************************************************
  // 2. OBTENER INCIDENCIAS PAGINADAS
  // *********************************************************

  Future<void> _onObtenerIncidenciasPaginadas(
    ObtenerIncidenciasPaginadas event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasListadoResponse>(
      emit: emit,
      operacion: OperacionIncidencias.listado,
      actual: state.listado,
      mensajeError: 'Ocurrió un error al obtener las incidencias.',
      ejecutar: () => incidenciasUseCases.getIncidenciasPaginadas.run(
        filters: event.filters,
      ),
      actualizar: (estado, resultado) => estado.copyWith(listado: resultado),
    );
  }

  // *********************************************************
  // 3. OBTENER DETALLE
  // *********************************************************

  Future<void> _onObtenerIncidenciaDetalle(
    ObtenerIncidenciaDetalle event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasDetalleResponse>(
      emit: emit,
      operacion: OperacionIncidencias.detalle,
      actual: state.detalle,
      idIncidencia: event.idIncidencia,
      mensajeError: 'Ocurrió un error al obtener la incidencia.',
      ejecutar: () => incidenciasUseCases.getIncidenciaById.run(
        idIncidencia: event.idIncidencia,
      ),
      actualizar: (estado, resultado) => estado.copyWith(detalle: resultado),
    );
  }

  // *********************************************************
  // 4. AGREGAR ARCHIVOS
  // *********************************************************

  Future<void> _onAgregarArchivosIncidencia(
    AgregarArchivosIncidencia event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasCargaArchivosResponse>(
      emit: emit,
      operacion: OperacionIncidencias.cargaArchivos,
      actual: state.cargaArchivos,
      idIncidencia: event.idIncidencia,
      bloquearDuplicados: true,
      mensajeError: 'Ocurrió un error al agregar las evidencias.',
      ejecutar: () => incidenciasUseCases.agregarArchivos.run(
        idIncidencia: event.idIncidencia,
        request: event.request,
      ),
      actualizar: (estado, resultado) =>
          estado.copyWith(cargaArchivos: resultado),
    );
  }

  // *********************************************************
  // 5. OBTENER ARCHIVOS
  // *********************************************************

  Future<void> _onObtenerArchivosIncidencia(
    ObtenerArchivosIncidencia event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasArchivosResponse>(
      emit: emit,
      operacion: OperacionIncidencias.archivos,
      actual: state.archivos,
      idIncidencia: event.idIncidencia,
      mensajeError: 'Ocurrió un error al obtener las evidencias.',
      ejecutar: () => incidenciasUseCases.getArchivosPorIncidencia.run(
        idIncidencia: event.idIncidencia,
      ),
      actualizar: (estado, resultado) => estado.copyWith(archivos: resultado),
    );
  }

  // *********************************************************
  // 6. OBTENER ARCHIVO POR ID
  // *********************************************************

  Future<void> _onObtenerArchivoIncidencia(
    ObtenerArchivoIncidencia event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasArchivoResponse>(
      emit: emit,
      operacion: OperacionIncidencias.archivo,
      actual: state.archivo,
      idIncidencia: event.idIncidencia,
      idArchivo: event.idArchivo,
      mensajeError: 'Ocurrió un error al obtener el archivo.',
      ejecutar: () => incidenciasUseCases.getArchivoPorId.run(
        idIncidencia: event.idIncidencia,
        idArchivo: event.idArchivo,
      ),
      actualizar: (estado, resultado) => estado.copyWith(archivo: resultado),
    );
  }

  // *********************************************************
  // 7. ELIMINAR ARCHIVO
  // *********************************************************

  Future<void> _onEliminarArchivoIncidencia(
    EliminarArchivoIncidencia event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasEliminarArchivoResponse>(
      emit: emit,
      operacion: OperacionIncidencias.eliminacionArchivo,
      actual: state.eliminacionArchivo,
      idIncidencia: event.idIncidencia,
      idArchivo: event.idArchivo,
      bloquearDuplicados: true,
      mensajeError: 'Ocurrió un error al eliminar el archivo.',
      ejecutar: () => incidenciasUseCases.deleteArchivo.run(
        idIncidencia: event.idIncidencia,
        idArchivo: event.idArchivo,
      ),
      actualizar: (estado, resultado) =>
          estado.copyWith(eliminacionArchivo: resultado),
    );
  }

  // *********************************************************
  // 8. ACTUALIZAR INCIDENCIA
  // *********************************************************

  Future<void> _onActualizarIncidencia(
    ActualizarIncidencia event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasActualizacionResponse>(
      emit: emit,
      operacion: OperacionIncidencias.actualizacion,
      actual: state.actualizacion,
      idIncidencia: event.idIncidencia,
      bloquearDuplicados: true,
      mensajeError: 'Ocurrió un error al actualizar la incidencia.',
      ejecutar: () => incidenciasUseCases.updateIncidencia.run(
        idIncidencia: event.idIncidencia,
        request: event.request,
      ),
      actualizar: (estado, resultado) =>
          estado.copyWith(actualizacion: resultado),
    );
  }

  // *********************************************************
  // 9. CAMBIAR ESTADO
  // *********************************************************

  Future<void> _onCambiarEstadoIncidencia(
    CambiarEstadoIncidencia event,
    Emitter<IncidenciasState> emit,
  ) {
    return _ejecutar<IncidenciasCambioEstadoResponse>(
      emit: emit,
      operacion: OperacionIncidencias.cambioEstado,
      actual: state.cambioEstado,
      idIncidencia: event.idIncidencia,
      bloquearDuplicados: true,
      mensajeError: 'Ocurrió un error al cambiar el estado de la incidencia.',
      ejecutar: () => incidenciasUseCases.changeIncidenciaEstado.run(
        idIncidencia: event.idIncidencia,
        request: event.request,
      ),
      actualizar: (estado, resultado) =>
          estado.copyWith(cambioEstado: resultado),
    );
  }

  // *********************************************************
  // EJECUCIÓN COMPARTIDA
  // *********************************************************

  Future<void> _ejecutar<T>({
    required Emitter<IncidenciasState> emit,
    required OperacionIncidencias operacion,
    required OperacionIncidenciaState<T> actual,
    required Future<Resource<T>> Function() ejecutar,
    required IncidenciasState Function(
      IncidenciasState estado,
      OperacionIncidenciaState<T> resultado,
    )
    actualizar,
    required String mensajeError,
    int? idIncidencia,
    int? idArchivo,
    bool bloquearDuplicados = false,
  }) async {
    // Evita repetir la misma operación de escritura
    // mientras su solicitud continúa en curso.
    if (bloquearDuplicados && actual.estaCargando) {
      return;
    }

    final version = ++_secuencia;
    _versiones[operacion] = version;

    final mismoRecurso =
        actual.idIncidencia == idIncidencia && actual.idArchivo == idArchivo;

    // Conserva el resultado anterior mientras recarga
    // el mismo recurso.
    emit(
      actualizar(
        state,
        OperacionIncidenciaState<T>(
          estado: EstadoOperacionIncidencia.cargando,
          resultado: mismoRecurso ? actual.resultado : null,
          idIncidencia: idIncidencia,
          idArchivo: idArchivo,
          ejecucion: version,
        ),
      ),
    );

    Resource<T> resultado;

    try {
      resultado = await ejecutar();

      // El caso de uso debe entregar un resultado final.
      if (resultado is! Success<T> && resultado is! ErrorData<T>) {
        resultado = ErrorData<T>(
          message: 'El caso de uso no devolvió un resultado final válido.',
        );
      }
    } catch (error) {
      resultado = ErrorData<T>(message: mensajeError, error: error.toString());
    }

    // Ignora respuestas de solicitudes reemplazadas.
    // No cancela la petición HTTP que ya estaba ejecutándose.
    if (isClosed || emit.isDone || _versiones[operacion] != version) {
      return;
    }

    // Utiliza el estado actual para conservar los cambios
    // realizados por las otras operaciones del BLoC.
    emit(
      actualizar(
        state,
        OperacionIncidenciaState<T>(
          estado: resultado is Success<T>
              ? EstadoOperacionIncidencia.exito
              : EstadoOperacionIncidencia.error,
          resultado: resultado,
          idIncidencia: idIncidencia,
          idArchivo: idArchivo,
          ejecucion: version,
        ),
      ),
    );
  }
}
