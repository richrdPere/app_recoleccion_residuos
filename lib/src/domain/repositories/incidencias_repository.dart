import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class IncidenciasRepository {
  // 1. CREAR INCIDENCIA
  Future<Resource<ApiResponse<CreateIncidenciaDataModel>>> createIncidencia({
    required CreateIncidenciaRequest request,
  });

  // 2. OBTENER INCIDENCIAS PAGINADAS
  Future<Resource<ApiResponse<IncidenciasPaginadasDataModel>>>
  getIncidenciasPaginadas({required IncidenciasPaginadasFilters filters});

  // 3. OBTENER INCIDENCIA POR ID
  Future<Resource<ApiResponse<IncidenciaDetalleModel>>> getIncidenciaById({
    required int idIncidencia,
  });

  // 4. AGREGAR ARCHIVOS A UNA INCIDENCIA
  Future<Resource<ApiResponse<List<IncidenciaArchivoCreadoModel>>>>
  agregarArchivos({
    required int idIncidencia,
    required AgregarIncidenciaArchivosRequest request,
  });

  // 5. OBTENER ARCHIVOS POR INCIDENCIA
  Future<Resource<ApiResponse<List<IncidenciaArchivoListadoModel>>>>
  getArchivosPorIncidencia({required int idIncidencia});

  // 6. OBTENER ARCHIVO POR INCIDENCIA E ID DE ARCHIVO
  Future<Resource<ApiResponse<IncidenciaArchivoDetalleModel>>> getArchivoPorId({
    required int idIncidencia,
    required int idArchivo,
  });

  // 7. ELIMINAR ARCHIVO DE INCIDENCIA
  Future<Resource<ApiResponse<DeleteIncidenciaArchivoDataModel>>>
  deleteArchivo({required int idIncidencia, required int idArchivo});

  // 8. ACTUALIZAR INCIDENCIA
  Future<Resource<ApiResponse<UpdateIncidenciaDataModel>>> updateIncidencia({
    required int idIncidencia,
    required UpdateIncidenciaRequest request,
  });

  // 9. CAMBIAR ESTADO DE INCIDENCIA
  Future<Resource<ApiResponse<ChangeIncidenciaEstadoDataModel>>>
  changeIncidenciaEstado({
    required int idIncidencia,
    required ChangeIncidenciaEstadoRequest request,
  });
}
