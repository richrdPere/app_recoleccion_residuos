import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// *********************************************************
// EVENTO BASE
// *********************************************************

abstract class IncidenciasEvent {
  const IncidenciasEvent();
}

// *********************************************************
// 1. CREAR INCIDENCIA
// *********************************************************

class CrearIncidencia extends IncidenciasEvent {
  final CreateIncidenciaRequest request;

  const CrearIncidencia({required this.request});
}

// *********************************************************
// 2. OBTENER INCIDENCIAS PAGINADAS
// *********************************************************

class ObtenerIncidenciasPaginadas extends IncidenciasEvent {
  final IncidenciasPaginadasFilters filters;

  const ObtenerIncidenciasPaginadas({required this.filters});
}

// *********************************************************
// 3. OBTENER DETALLE DE INCIDENCIA
// *********************************************************

class ObtenerIncidenciaDetalle extends IncidenciasEvent {
  final int idIncidencia;

  const ObtenerIncidenciaDetalle({required this.idIncidencia});
}

// *********************************************************
// 4. AGREGAR ARCHIVOS
// *********************************************************

class AgregarArchivosIncidencia extends IncidenciasEvent {
  final int idIncidencia;
  final AgregarIncidenciaArchivosRequest request;

  const AgregarArchivosIncidencia({
    required this.idIncidencia,
    required this.request,
  });
}

// *********************************************************
// 5. OBTENER ARCHIVOS DE LA INCIDENCIA
// *********************************************************

class ObtenerArchivosIncidencia extends IncidenciasEvent {
  final int idIncidencia;

  const ObtenerArchivosIncidencia({required this.idIncidencia});
}

// *********************************************************
// 6. OBTENER ARCHIVO POR ID
// *********************************************************

class ObtenerArchivoIncidencia extends IncidenciasEvent {
  final int idIncidencia;
  final int idArchivo;

  const ObtenerArchivoIncidencia({
    required this.idIncidencia,
    required this.idArchivo,
  });
}

// *********************************************************
// 7. ELIMINAR ARCHIVO
// *********************************************************

class EliminarArchivoIncidencia extends IncidenciasEvent {
  final int idIncidencia;
  final int idArchivo;

  const EliminarArchivoIncidencia({
    required this.idIncidencia,
    required this.idArchivo,
  });
}

// *********************************************************
// 8. ACTUALIZAR INCIDENCIA
// *********************************************************

class ActualizarIncidencia extends IncidenciasEvent {
  final int idIncidencia;
  final UpdateIncidenciaRequest request;

  const ActualizarIncidencia({
    required this.idIncidencia,
    required this.request,
  });
}

// *********************************************************
// 9. CAMBIAR ESTADO
// *********************************************************

class CambiarEstadoIncidencia extends IncidenciasEvent {
  final int idIncidencia;
  final ChangeIncidenciaEstadoRequest request;

  const CambiarEstadoIncidencia({
    required this.idIncidencia,
    required this.request,
  });
}
