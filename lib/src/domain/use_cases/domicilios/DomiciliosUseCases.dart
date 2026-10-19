import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class DomiciliosUseCases {
  CreateCiudadanoDomicilioUC createCiudadanoDomicilio;
  DeleteCiudadanoDomicilioUC deleteCiudadanoDomicilio;
  GetDomicilioCronogramaUC getDomicilioCronograma;
  GetMisDomiciliosUC getMisDomicilios;
  SetPrincipalCiudadanoDomicilioUC setPrincipalCiudadanoDomicilio;
  UpdateCiudadanoDomicilioUC updateCiudadanoDomicilio;

  DomiciliosUseCases({
    required this.createCiudadanoDomicilio,
    required this.deleteCiudadanoDomicilio,
    required this.getDomicilioCronograma,
    required this.getMisDomicilios,
    required this.setPrincipalCiudadanoDomicilio,
    required this.updateCiudadanoDomicilio,
  });
}
