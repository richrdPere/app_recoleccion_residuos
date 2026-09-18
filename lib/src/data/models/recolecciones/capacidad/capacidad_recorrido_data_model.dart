// *********************************************************
// DATA
// *********************************************************
class CapacidadRecorridoDataModel {
  final int idRecorrido;
  final String estadoRecorrido;
  final CapacidadVehiculoModel vehiculo;
  final CapacidadResumenModel capacidad;
  final CapacidadRecoleccionesModel recolecciones;

  CapacidadRecorridoDataModel.fromJson(Map<String, dynamic> json)
    : idRecorrido = (json['id_recorrido'] as num).toInt(),
      estadoRecorrido = json['estado_recorrido'] as String,
      vehiculo = CapacidadVehiculoModel.fromJson(
        Map<String, dynamic>.from(json['vehiculo'] as Map),
      ),
      capacidad = CapacidadResumenModel.fromJson(
        Map<String, dynamic>.from(json['capacidad'] as Map),
      ),
      recolecciones = CapacidadRecoleccionesModel.fromJson(
        Map<String, dynamic>.from(json['recolecciones'] as Map),
      );
}

// *********************************************************
// VEHÍCULO
// *********************************************************
class CapacidadVehiculoModel {
  final int idVehiculo;
  final String placa;
  final double capacidadMaxima;
  final String unidadCapacidad;

  CapacidadVehiculoModel.fromJson(Map<String, dynamic> json)
    : idVehiculo = (json['id_vehiculo'] as num).toInt(),
      placa = json['placa'] as String,
      capacidadMaxima = (json['capacidad_maxima'] as num).toDouble(),
      unidadCapacidad = json['unidad_capacidad'] as String;
}

// *********************************************************
// RESUMEN DE CAPACIDAD
// *********************************************************
class CapacidadResumenModel {
  final double cantidadAcumulada;
  final double capacidadRestante;
  final double cantidadExcedida;
  final double porcentaje;
  final String estado;
  final double umbralAdvertencia;
  final bool capacidadCompleta;
  final bool existeSobrecarga;

  CapacidadResumenModel.fromJson(Map<String, dynamic> json)
    : cantidadAcumulada = (json['cantidad_acumulada'] as num).toDouble(),
      capacidadRestante = (json['capacidad_restante'] as num).toDouble(),
      cantidadExcedida = (json['cantidad_excedida'] as num).toDouble(),
      porcentaje = (json['porcentaje'] as num).toDouble(),
      estado = json['estado'] as String,
      umbralAdvertencia = (json['umbral_advertencia'] as num).toDouble(),
      capacidadCompleta = json['capacidad_completa'] as bool,
      existeSobrecarga = json['existe_sobrecarga'] as bool;

  // Solo limita la representación visual de la barra.
  // El porcentaje original conserva valores superiores a 100.
  double get porcentajeNormalizado =>
      (porcentaje / 100).clamp(0.0, 1.0).toDouble();
}

// *********************************************************
// CONTEO DE RECOLECCIONES
// *********************************************************
class CapacidadRecoleccionesModel {
  final int total;
  final int conCantidad;
  final int sinCantidad;

  CapacidadRecoleccionesModel.fromJson(Map<String, dynamic> json)
    : total = (json['total'] as num).toInt(),
      conCantidad = (json['con_cantidad'] as num).toInt(),
      sinCantidad = (json['sin_cantidad'] as num).toInt();
}
