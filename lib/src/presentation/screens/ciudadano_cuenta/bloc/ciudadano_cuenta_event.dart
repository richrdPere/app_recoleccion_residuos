import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class CiudadanoCuentaEvent {
  const CiudadanoCuentaEvent();
}

// *********************************************************
// CONSULTAR PERFIL
// *********************************************************

class CiudadanoCuentaRequested extends CiudadanoCuentaEvent {
  const CiudadanoCuentaRequested();
}

// *********************************************************
// CREAR PERFIL
// *********************************************************

class CiudadanoCuentaCreateSubmitted extends CiudadanoCuentaEvent {
  final CreateCiudadanoPerfilRequest request;

  const CiudadanoCuentaCreateSubmitted({required this.request});
}

// *********************************************************
// ACTUALIZAR PERFIL
// *********************************************************

class CiudadanoCuentaUpdateSubmitted extends CiudadanoCuentaEvent {
  final UpdateCiudadanoPerfilRequest request;

  const CiudadanoCuentaUpdateSubmitted({required this.request});
}

// *********************************************************
// LIMPIAR ESTADO AL CERRAR O CAMBIAR SESIÓN
// *********************************************************

class CiudadanoCuentaReset extends CiudadanoCuentaEvent {
  const CiudadanoCuentaReset();
}
