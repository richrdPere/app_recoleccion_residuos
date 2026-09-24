import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class RecoleccionRepository {
  /// 1. REGISTRAR RECOLECCIÓN
  Future<Resource<ApiResponse<RegistrarRecoleccionDataModel>>>
  registrarRecoleccion({required RegistrarRecoleccionRequest request});

  /// 2. REGISTRAR LOTE DE RECOLECCIONES OFFLINE
  Future<Resource<ApiResponse<RegistrarRecoleccionLoteDataModel>>>
  registrarRecoleccionLote({required RegistrarRecoleccionLoteRequest request});

  /// 3. OBTENER PUNTOS DEL RECORRIDO
  Future<Resource<ApiResponse<List<PuntoRecorridoDataModel>>>>
  getPuntosRecorrido({required int idRecorrido});

  /// 4. OBTENER PROGRESO DEL RECORRIDO
  Future<Resource<ApiResponse<RecorridoProgresoDataModel>>>
  getRecorridoProgreso({required int idRecorrido});

  /// 5. REGISTRAR EVIDENCIA DE RECOLECCIÓN
  Future<Resource<ApiResponse<RecoleccionEvidenciaDataModel>>>
  registrarEvidencia({
    required int idRecoleccion,
    required RegistrarEvidenciaRequest request,
  });

  /// 6. OBTENER RECOLECCIÓN POR ID
  Future<Resource<ApiResponse<RecoleccionDetalleDataModel>>>
  getRecoleccionById({required int idRecoleccion});
}
