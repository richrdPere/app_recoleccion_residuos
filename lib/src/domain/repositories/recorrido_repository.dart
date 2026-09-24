import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class RecorridoRepository {
  /// 1. INICIAR RECORRIDO
  Future<Resource<ApiResponse<RecorridoDataModel>>> iniciarRecorrido({
    required int idProgramacion,
    required IniciarRecorridoRequest request,
  });

  /// 2. PAUSAR RECORRIDO
  Future<Resource<ApiResponse<RecorridoDataModel>>> pausarRecorrido({
    required int idRecorrido,
    required PausarRecorridoRequest request,
  });

  /// 3. REANUDAR RECORRIDO
  Future<Resource<ApiResponse<RecorridoDataModel>>> reanudarRecorrido({
    required int idRecorrido,
    required ReanudarRecorridoRequest request,
  });

  /// 4. FINALIZAR RECORRIDO
  Future<Resource<ApiResponse<RecorridoDataModel>>> finalizarRecorrido({
    required int idRecorrido,
    required FinalizarRecorridoRequest request,
  });

  /// 5. OBTENER RECORRIDO ACTIVO
  Future<Resource<ApiResponse<RecorridoDataModel?>>> getRecorridoActivo();

  /// 6. OBTENER MIS RECORRIDOS PAGINADOS
  Future<Resource<ApiResponse<MisRecorridosDataModel>>> getMisRecorridos({
    required int page,
    required int limit,
  });

  /// 7. OBTENER RECORRIDO POR ID
  Future<Resource<ApiResponse<RecorridoDataModel>>> getRecorridoById({
    required int idRecorrido,
  });
}
