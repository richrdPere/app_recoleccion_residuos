// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class NotificacionesRepositoryImpl implements NotificacionesRepository {
  final NotificacionesService notificacionesService;
  final AuthRepository authRepository;

  NotificacionesRepositoryImpl(this.notificacionesService, this.authRepository);

  // *********************************************************
  // 1. OBTENER MIS NOTIFICACIONES
  // *********************************************************
  @override
  Future<Resource<ApiResponse<GetMisNotificacionesDataModel>>>
  getMisNotificaciones({required GetMisNotificacionesRequest query}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await notificacionesService.getMisNotificaciones(token: token);
  }

  // *********************************************************
  // 2. OBTENER TOTAL DE NOTIFICACIONES NO LEÍDAS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<GetTotalNoLeidasDataModel>>>
  getTotalNoLeidas() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await notificacionesService.getTotalNoLeidas(token: token);
  }

  // *********************************************************
  // 3. OBTENER NOTIFICACIÓN POR ID
  // *********************************************************
  @override
  Future<Resource<ApiResponse<GetNotificacionByIdDataModel>>>
  getNotificacionById({required int id}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await notificacionesService.getNotificacionById(
      id: id,
      token: token,
    );
  }

  // *********************************************************
  // 4. MARCAR NOTIFICACIÓN COMO LEÍDA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<MarcarNotificacionLeidaDataModel>>>
  marcarNotificacionLeida({required int id}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await notificacionesService.marcarNotificacionLeida(
      id: id,
      token: token,
    );
  }

  // *********************************************************
  // 5. MARCAR TODAS LAS NOTIFICACIONES COMO LEÍDAS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>>
  marcarTodasNotificacionesLeidas() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await notificacionesService.marcarTodasNotificacionesLeidas(
      token: token,
    );
  }

  // *********************************************************
  // 6. ARCHIVAR NOTIFICACIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ArchivarNotificacionDataModel>>>
  archivarNotificacion({required int id}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await notificacionesService.archivarNotificacion(
      id: id,
      token: token,
    );
  }
}
