// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Sync
import 'package:app_recoleccion_residuos/src/config/core/sync/operacion_offline.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingService trackingService;
  final AuthRepository authRepository;

  TrackingRepositoryImpl(this.trackingService, this.authRepository);

  // *********************************************************
  // 1. REGISTRAR UBICACIÓN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegistrarUbicacionDataModel>>>
  registrarUbicacion({required RegistrarUbicacionRequest request}) {
    return OperacionOffline.instance.guardar<RegistrarUbicacionDataModel>(
      'gps',
      request.toJson(),
    );
    // final token = await authRepository.getToken();
    // if (token == null) {
    //   return ErrorData(message: 'No existe una sesión iniciada.');
    // }

    // return await trackingService.registrarUbicacion(
    //   request: request,
    //   token: token,
    // );
  }

  // *********************************************************
  // 2. REGISTRAR UBICACIONES POR LOTE
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegistrarUbicacionLoteDataModel>>>
  registrarUbicacionLote({required RegistrarUbicacionLoteRequest request}) {
    final json = request.toJson();

    return OperacionOffline.instance
        .guardarLote<RegistrarUbicacionLoteDataModel>(
          'gps',
          request.idRecorrido,
          (json['ubicaciones'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(),
        );

    // final token = await authRepository.getToken();
    // if (token == null) {
    //   return ErrorData(message: 'No existe una sesión iniciada.');
    // }

    // return await trackingService.registrarUbicacionLote(
    //   request: request,
    //   token: token,
    // );
  }
}
