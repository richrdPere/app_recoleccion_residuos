import 'package:app_recoleccion_residuos/src/data/models/models.dart';

abstract class CiudadanoDomiciliosEvent {
  const CiudadanoDomiciliosEvent();
}

// *********************************************************
// CONSULTAR DOMICILIOS
// *********************************************************

class CiudadanoDomiciliosRequested extends CiudadanoDomiciliosEvent {
  final bool incluirInactivos;

  const CiudadanoDomiciliosRequested({this.incluirInactivos = false});
}

// *********************************************************
// CREAR DOMICILIO
// *********************************************************

class CiudadanoDomicilioCreateSubmitted extends CiudadanoDomiciliosEvent {
  final CreateCiudadanoDomicilioRequest request;

  const CiudadanoDomicilioCreateSubmitted({required this.request});
}

// *********************************************************
// ACTUALIZAR DOMICILIO
// *********************************************************

class CiudadanoDomicilioUpdateSubmitted extends CiudadanoDomiciliosEvent {
  final int idDomicilio;
  final UpdateCiudadanoDomicilioRequest request;

  const CiudadanoDomicilioUpdateSubmitted({
    required this.idDomicilio,
    required this.request,
  });
}

// *********************************************************
// ESTABLECER PRINCIPAL
// *********************************************************

class CiudadanoDomicilioPrincipalSubmitted extends CiudadanoDomiciliosEvent {
  final int idDomicilio;

  const CiudadanoDomicilioPrincipalSubmitted({required this.idDomicilio});
}

// *********************************************************
// ELIMINAR DOMICILIO
// *********************************************************

class CiudadanoDomicilioDeleteSubmitted extends CiudadanoDomiciliosEvent {
  final int idDomicilio;

  const CiudadanoDomicilioDeleteSubmitted({required this.idDomicilio});
}

// *********************************************************
// LIMPIAR ESTADO
// *********************************************************

class CiudadanoDomiciliosReset extends CiudadanoDomiciliosEvent {
  const CiudadanoDomiciliosReset();
}
