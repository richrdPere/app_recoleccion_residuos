import 'package:app_recoleccion_residuos/src/data/models/models.dart';

enum PerfilStatus {
  initial,
  loading,
  refreshing,
  success,
  failure,
}

class PerfilState {
  final PerfilStatus status;
  final ApiResponse<UsuarioDataModel>? response;
  final String? errorMessage;
  final int? statusCode;

  const PerfilState({
    this.status = PerfilStatus.initial,
    this.response,
    this.errorMessage,
    this.statusCode,
  });

  // *********************************************************
  // GETTERS
  // *********************************************************
  UsuarioDataModel? get usuario => response?.data;

  bool get hasData => usuario != null;

  bool get isLoading => status == PerfilStatus.loading;

  bool get isRefreshing => status == PerfilStatus.refreshing;

  bool get isBusy => isLoading || isRefreshing;

  bool get hasError => status == PerfilStatus.failure;
}