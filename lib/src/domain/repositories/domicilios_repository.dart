import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

abstract class DomiciliosRepository {
  /// 1. REGISTRAR DOMICILIO CIUDADANO
  Future<Resource<ApiResponse<CreateCiudadanoDomicilioDataModel>>>
  createCiudadanoDomicilio({required CreateCiudadanoDomicilioRequest request});

  /// 2. OBTENER MIS DOMICILIOS
  Future<Resource<ApiResponse<List<GetMisDomiciliosDataModel>>>>
  getMisDomicilios({bool incluirInactivos = false});

  /// 3. ACTUALIZAR DOMICILIO CIUDADANO
  Future<Resource<ApiResponse<UpdateCiudadanoDomicilioDataModel>>>
  updateCiudadanoDomicilio({
    required int idDomicilio,
    required UpdateCiudadanoDomicilioRequest request,
  });

  /// 4. ESTABLECER DOMICILIO PRINCIPAL
  Future<Resource<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>>
  setPrincipalCiudadanoDomicilio({required int idDomicilio});

  /// 5. OBTENER CRONOGRAMA DEL DOMICILIO
  Future<Resource<ApiResponse<GetDomicilioCronogramaDataModel>>>
  getDomicilioCronograma({required int idDomicilio});

  /// 6. ELIMINAR DOMICILIO CIUDADANO
  Future<Resource<ApiResponse<DeleteCiudadanoDomicilioDataModel>>>
  deleteCiudadanoDomicilio({required int idDomicilio});
}
