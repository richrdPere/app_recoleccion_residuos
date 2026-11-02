abstract class CiudadanoMapaEvent {
  const CiudadanoMapaEvent();
}

/// Consulta domicilios y el servicio del domicilio seleccionado.
class CiudadanoMapaRequested extends CiudadanoMapaEvent {
  const CiudadanoMapaRequested();
}

class CiudadanoMapaDomicilioSelected extends CiudadanoMapaEvent {
  final int idDomicilio;

  const CiudadanoMapaDomicilioSelected({required this.idDomicilio});
}

/// Actualiza únicamente el servicio del domicilio seleccionado.
class CiudadanoMapaServicioRequested extends CiudadanoMapaEvent {
  const CiudadanoMapaServicioRequested();
}

/// Limpia los datos e invalida consultas pendientes.
class CiudadanoMapaReset extends CiudadanoMapaEvent {
  const CiudadanoMapaReset();
}
