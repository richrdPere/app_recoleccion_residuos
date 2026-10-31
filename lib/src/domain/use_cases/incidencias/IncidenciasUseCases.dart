import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

class IncidenciasUseCases {
  AgregarArchivosUC agregarArchivos;
  ChangeIncidenciaEstadoUC changeIncidenciaEstado;
  CreateIncidenciaUC createIncidencia;
  DeleteArchivoUC deleteArchivo;
  GetArchivoPorIdUC getArchivoPorId;
  GetArchivosPorIncidenciaUC getArchivosPorIncidencia;
  GetIncidenciaByIdUC getIncidenciaById;
  GetIncidenciasPaginadasUC getIncidenciasPaginadas;
  UpdateIncidenciaUC updateIncidencia;

  IncidenciasUseCases({
    required this.agregarArchivos,
    required this.changeIncidenciaEstado,
    required this.createIncidencia,
    required this.deleteArchivo,
    required this.getArchivoPorId,
    required this.getArchivosPorIncidencia,
    required this.getIncidenciaById,
    required this.getIncidenciasPaginadas,
    required this.updateIncidencia,
  });
}
