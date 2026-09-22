// *********************************************************
// DATA DEL LOTE
// *********************************************************
class RegistrarUbicacionLoteDataModel {
  final int recibidas;
  final int registradas;
  final int duplicadas;
  final int rechazadas;
  final List<UbicacionLoteResultadoModel> resultados;

  RegistrarUbicacionLoteDataModel.fromJson(Map<String, dynamic> json)
    : recibidas = (json['recibidas'] as num).toInt(),
      registradas = (json['registradas'] as num).toInt(),
      duplicadas = (json['duplicadas'] as num).toInt(),
      rechazadas = (json['rechazadas'] as num).toInt(),
      resultados = (json['resultados'] as List)
          .map(
            (item) => UbicacionLoteResultadoModel.fromJson(
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
class UbicacionLoteResultadoModel {
  final int index;
  final String? claveIdempotencia;
  final String estado;
  final String? codigo;
  final String? mensaje;

  // Conserva campos adicionales hasta confirmar el JSON
  // de los resultados REGISTRADA y DUPLICADA.
  final Map<String, dynamic> datosAdicionales;

  UbicacionLoteResultadoModel.fromJson(Map<String, dynamic> json)
    : index = (json['index'] as num).toInt(),
      claveIdempotencia = json['clave_idempotencia'] as String?,
      estado = json['estado'] as String,
      codigo = json['codigo'] as String?,
      mensaje = json['mensaje'] as String?,
      datosAdicionales = Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(json)
          ..remove('index')
          ..remove('clave_idempotencia')
          ..remove('estado')
          ..remove('codigo')
          ..remove('mensaje'),
      );

  bool get registrada => estado == 'REGISTRADA';

  bool get duplicada => estado == 'DUPLICADA';

  bool get rechazada => estado == 'RECHAZADA';

  bool get confirmada => registrada || duplicada;
}
