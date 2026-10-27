import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ProgramacionesState {
  final Resource<ApiResponse<MisAsignacionesDataModel>> misAsignaciones;

  final Resource<ApiResponse<ProgramacionDetalleDataModel>> programacionDetalle;

  final Resource<ApiResponse<ResponderAsignacionDataModel>> respuestaAsignacion;

  /// Identifica el detalle solicitado.
  final int? idProgramacionDetalle;

  /// Identifica la asignación cuya respuesta se está procesando
  /// o fue procesada por última vez.
  final int? idProgramacionPersonalRespuesta;

  const ProgramacionesState({
    required this.misAsignaciones,
    required this.programacionDetalle,
    required this.respuestaAsignacion,
    this.idProgramacionDetalle,
    this.idProgramacionPersonalRespuesta,
  });

  factory ProgramacionesState.initial() {
    return ProgramacionesState(
      misAsignaciones: Initial<ApiResponse<MisAsignacionesDataModel>>(),
      programacionDetalle: Initial<ApiResponse<ProgramacionDetalleDataModel>>(),
      respuestaAsignacion: Initial<ApiResponse<ResponderAsignacionDataModel>>(),
    );
  }

  ProgramacionesState copyWith({
    Resource<ApiResponse<MisAsignacionesDataModel>>? misAsignaciones,
    Resource<ApiResponse<ProgramacionDetalleDataModel>>? programacionDetalle,
    Resource<ApiResponse<ResponderAsignacionDataModel>>? respuestaAsignacion,
    int? idProgramacionDetalle,
    int? idProgramacionPersonalRespuesta,
  }) {
    return ProgramacionesState(
      misAsignaciones: misAsignaciones ?? this.misAsignaciones,
      programacionDetalle: programacionDetalle ?? this.programacionDetalle,
      respuestaAsignacion: respuestaAsignacion ?? this.respuestaAsignacion,
      idProgramacionDetalle:
          idProgramacionDetalle ?? this.idProgramacionDetalle,
      idProgramacionPersonalRespuesta:
          idProgramacionPersonalRespuesta ??
          this.idProgramacionPersonalRespuesta,
    );
  }

  // *********************************************************
  // MIS ASIGNACIONES
  // *********************************************************

  bool get cargandoAsignaciones =>
      misAsignaciones is Loading<ApiResponse<MisAsignacionesDataModel>>;

  ApiResponse<MisAsignacionesDataModel>? get asignaciones {
    final recurso = misAsignaciones;

    if (recurso is Success<ApiResponse<MisAsignacionesDataModel>>) {
      return recurso.data;
    }

    return null;
  }

  String? get errorAsignaciones {
    final recurso = misAsignaciones;

    if (recurso is ErrorData<ApiResponse<MisAsignacionesDataModel>>) {
      return recurso.fullMessage;
    }

    return null;
  }

  // *********************************************************
  // DETALLE
  // *********************************************************

  bool get cargandoDetalle =>
      programacionDetalle is Loading<ApiResponse<ProgramacionDetalleDataModel>>;

  ApiResponse<ProgramacionDetalleDataModel>? get detalle {
    final recurso = programacionDetalle;

    if (recurso is Success<ApiResponse<ProgramacionDetalleDataModel>>) {
      return recurso.data;
    }

    return null;
  }

  String? get errorDetalle {
    final recurso = programacionDetalle;

    if (recurso is ErrorData<ApiResponse<ProgramacionDetalleDataModel>>) {
      return recurso.fullMessage;
    }

    return null;
  }

  // *********************************************************
  // RESPUESTA DE ASIGNACIÓN
  // *********************************************************

  bool get respondiendoAsignacion =>
      respuestaAsignacion is Loading<ApiResponse<ResponderAsignacionDataModel>>;

  bool get asignacionRespondida =>
      respuestaAsignacion is Success<ApiResponse<ResponderAsignacionDataModel>>;

  ApiResponse<ResponderAsignacionDataModel>? get respuesta {
    final recurso = respuestaAsignacion;

    if (recurso is Success<ApiResponse<ResponderAsignacionDataModel>>) {
      return recurso.data;
    }

    return null;
  }

  String? get errorRespuesta {
    final recurso = respuestaAsignacion;

    if (recurso is ErrorData<ApiResponse<ResponderAsignacionDataModel>>) {
      return recurso.fullMessage;
    }

    return null;
  }

  bool estaRespondiendo(int idProgramacionPersonal) {
    return respondiendoAsignacion &&
        idProgramacionPersonalRespuesta == idProgramacionPersonal;
  }
}
