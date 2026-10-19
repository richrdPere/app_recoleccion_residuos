abstract class CiudadanoInicioEvent {
  const CiudadanoInicioEvent();
}

// *********************************************************
// CARGAR O ACTUALIZAR INICIO
// *********************************************************

class CiudadanoInicioRequested extends CiudadanoInicioEvent {
  const CiudadanoInicioRequested();
}

// *********************************************************
// SELECCIONAR DOMICILIO PARA CONSULTAR
// *********************************************************

class CiudadanoInicioDomicilioSelected extends CiudadanoInicioEvent {
  final int idDomicilio;

  const CiudadanoInicioDomicilioSelected({required this.idDomicilio});
}

// *********************************************************
// REINTENTAR CRONOGRAMA
// *********************************************************

class CiudadanoInicioCronogramaRequested extends CiudadanoInicioEvent {
  const CiudadanoInicioCronogramaRequested();
}

// *********************************************************
// LIMPIAR AL CERRAR O CAMBIAR SESIÓN
// *********************************************************

class CiudadanoInicioReset extends CiudadanoInicioEvent {
  const CiudadanoInicioReset();
}
