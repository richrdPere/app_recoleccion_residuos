// *********************************************************
// ESTADO INDIVIDUAL
// *********************************************************
enum EstadoResultadoRecoleccion {
  registrada,
  duplicada,
  rechazada;

  static EstadoResultadoRecoleccion fromJson(String value) {
    switch (value) {
      case 'REGISTRADA':
        return EstadoResultadoRecoleccion.registrada;

      case 'DUPLICADA':
        return EstadoResultadoRecoleccion.duplicada;

      case 'RECHAZADA':
        return EstadoResultadoRecoleccion.rechazada;

      default:
        throw FormatException(
          'Estado de resultado de recolección desconocido: $value',
        );
    }
  }
}

// *********************************************************
// DATA DEL LOTE
// *********************************************************
class RegistrarRecoleccionLoteDataModel {
  final int recibidas;
  final int registradas;
  final int duplicadas;
  final int rechazadas;
  final List<RecoleccionLoteResultadoModel> resultados;

  RegistrarRecoleccionLoteDataModel.fromJson(Map<String, dynamic> json)
    : recibidas = (json['recibidas'] as num).toInt(),
      registradas = (json['registradas'] as num).toInt(),
      duplicadas = (json['duplicadas'] as num).toInt(),
      rechazadas = (json['rechazadas'] as num).toInt(),
      resultados = (json['resultados'] as List)
          .map(
            (item) => RecoleccionLoteResultadoModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

  bool get tieneRechazos => rechazadas > 0;

  int get totalConfirmadas => registradas + duplicadas;
}

// *********************************************************
// RESULTADO INDIVIDUAL
// *********************************************************
class RecoleccionLoteResultadoModel {
  final int index;
  final String? claveIdempotencia;
  final EstadoResultadoRecoleccion estado;
  final int? idRecoleccion;
  final String? codigo;
  final String? mensaje;

  RecoleccionLoteResultadoModel.fromJson(Map<String, dynamic> json)
    : index = (json['index'] as num).toInt(),
      claveIdempotencia = json['clave_idempotencia'] as String?,
      estado = EstadoResultadoRecoleccion.fromJson(json['estado'] as String),
      idRecoleccion = (json['id_recoleccion'] as num?)?.toInt(),
      codigo = json['codigo'] as String?,
      mensaje = json['mensaje'] as String?;

  bool get confirmada =>
      estado == EstadoResultadoRecoleccion.registrada ||
      estado == EstadoResultadoRecoleccion.duplicada;

  bool get rechazada => estado == EstadoResultadoRecoleccion.rechazada;
}
