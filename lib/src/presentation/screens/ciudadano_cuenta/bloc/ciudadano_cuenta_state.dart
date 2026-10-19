import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum CiudadanoCuentaStatus {
  initial,
  loading,
  ready,
  profileMissing,
  creating,
  updating,
  failure,
}

class CiudadanoCuentaState {
  final CiudadanoCuentaStatus status;
  final GetCiudadanoPerfilDataModel? perfil;

  final String? errorMessage;
  final String? successMessage;
  final int? statusCode;

  const CiudadanoCuentaState({
    this.status = CiudadanoCuentaStatus.initial,
    this.perfil,
    this.errorMessage,
    this.successMessage,
    this.statusCode,
  });

  // *********************************************************
  // INDICADORES
  // *********************************************************

  bool get isLoading => status == CiudadanoCuentaStatus.loading;

  bool get isCreating => status == CiudadanoCuentaStatus.creating;

  bool get isUpdating => status == CiudadanoCuentaStatus.updating;

  bool get isBusy => isLoading || isCreating || isUpdating;

  bool get hasProfile => perfil != null;

  bool get needsProfile => status == CiudadanoCuentaStatus.profileMissing;

  bool get isFailure => status == CiudadanoCuentaStatus.failure;

  // El detalle definitivo de permisos lo valida el backend.
  bool get isProfileActive => perfil?.estadoCiudadano == 'ACTIVO';

  // *********************************************************
  // COPY WITH
  // *********************************************************

  CiudadanoCuentaState copyWith({
    CiudadanoCuentaStatus? status,
    GetCiudadanoPerfilDataModel? perfil,
    String? errorMessage,
    String? successMessage,
    int? statusCode,
    bool clearProfile = false,
    bool clearMessages = false,
  }) {
    return CiudadanoCuentaState(
      status: status ?? this.status,
      perfil: clearProfile ? null : perfil ?? this.perfil,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
      statusCode: clearMessages ? null : statusCode ?? this.statusCode,
    );
  }
}
