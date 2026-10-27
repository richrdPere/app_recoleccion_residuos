import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

enum TrackingOperacion { ninguna, registrarUbicacion, registrarUbicacionesLote }

class TrackingState {
  final TrackingOperacion operacion;
  final bool procesando;

  final Resource<ApiResponse<RegistrarUbicacionDataModel>>? ubicacionResponse;

  final Resource<ApiResponse<RegistrarUbicacionLoteDataModel>>?
  ubicacionesLoteResponse;

  /// Excepción no controlada por el repositorio.
  ///
  /// Los errores devueltos como Resource permanecen en las respuestas.
  final String? errorInesperado;

  const TrackingState({
    this.operacion = TrackingOperacion.ninguna,
    this.procesando = false,
    this.ubicacionResponse,
    this.ubicacionesLoteResponse,
    this.errorInesperado,
  });
}
