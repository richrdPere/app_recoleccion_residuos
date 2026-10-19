
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class PrefNotificationUseCases {
  GetCiudadanoPreferenciasUC getCiudadanoPreferencias;
  UpdateCiudadanoPreferenciasUC updateCiudadanoPreferencias;

  PrefNotificationUseCases({
    required this.getCiudadanoPreferencias,
    required this.updateCiudadanoPreferencias,
  });
}
