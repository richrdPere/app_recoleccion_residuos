// *********************************************************
// RESULTADO DE DESACTIVACIÓN POR TOKEN
// *********************************************************
class DesactivarDispositivoTokenDataModel {
  final bool desactivado;
  final bool yaEstabaDesactivado;

  const DesactivarDispositivoTokenDataModel({
    required this.desactivado,
    required this.yaEstabaDesactivado,
  });

  factory DesactivarDispositivoTokenDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DesactivarDispositivoTokenDataModel(
      desactivado: json['desactivado'] as bool,
      yaEstabaDesactivado: json['ya_estaba_desactivado'] as bool,
    );
  }
}
