import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class DispositivosUseCases {
  DesactivarDispositivoPorTokenUC desactivarDispositivoPorToken;
  DesactivarDispositivoUC desactivarDispositivo;
  GetMisDispositivosUC getMisDispositivos;
  RegistrarDispositivoUC registrarDispositivo;

  DispositivosUseCases({
    required this.desactivarDispositivoPorToken,
    required this.desactivarDispositivo,
    required this.getMisDispositivos,
    required this.registrarDispositivo,
  });
}
