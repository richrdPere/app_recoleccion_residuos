class RecorridoProgresoDataModel {
  final int idRecorrido;

  final int totalPuntos;
  final int puntosAtendidos;
  final int puntosPendientes;

  final int puntosObligatorios;
  final int obligatoriosAtendidos;
  final int obligatoriosPendientes;

  final double porcentajeProgreso;
  final bool rutaCompletada;

  final Map<String, double> cantidadesPorUnidad;

  RecorridoProgresoDataModel.fromJson(Map<String, dynamic> json)
    : idRecorrido = (json['id_recorrido'] as num).toInt(),
      totalPuntos = (json['total_puntos'] as num).toInt(),
      puntosAtendidos = (json['puntos_atendidos'] as num).toInt(),
      puntosPendientes = (json['puntos_pendientes'] as num).toInt(),
      puntosObligatorios = (json['puntos_obligatorios'] as num).toInt(),
      obligatoriosAtendidos = (json['obligatorios_atendidos'] as num).toInt(),
      obligatoriosPendientes = (json['obligatorios_pendientes'] as num).toInt(),
      porcentajeProgreso = (json['porcentaje_progreso'] as num).toDouble(),
      rutaCompletada = json['ruta_completada'] as bool,
      cantidadesPorUnidad =
          Map<String, dynamic>.from(json['cantidades_por_unidad'] as Map).map(
            (unidad, cantidad) =>
                MapEntry(unidad, (cantidad as num).toDouble()),
          );

  // Para LinearProgressIndicator: valor entre 0 y 1.
  double get progresoNormalizado =>
      (porcentajeProgreso / 100).clamp(0.0, 1.0).toDouble();
}
