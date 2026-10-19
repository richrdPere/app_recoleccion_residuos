import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class CiudadanosUseCases {
  CreateCiudadanoPerfilUC createCiudadanoPerfil;
  GetMiPerfilCiudadanoUC getMiPerfilCiudadano;
  UpdateMiPerfilCiudadanoUC updateMiPerfilCiudadano;

  CiudadanosUseCases({
    required this.createCiudadanoPerfil,
    required this.getMiPerfilCiudadano,
    required this.updateMiPerfilCiudadano,
  });
}
