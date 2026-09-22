// *********************************************************
// RESULTADO DE DESACTIVACIÓN
// *********************************************************
class DesactivarDispositivoDataModel {
  final int idDispositivo;
  final String estadoDispositivo;
  final bool desactivado;
  final bool yaEstabaDesactivado;

  const DesactivarDispositivoDataModel({
    required this.idDispositivo,
    required this.estadoDispositivo,
    required this.desactivado,
    required this.yaEstabaDesactivado,
  });

  factory DesactivarDispositivoDataModel.fromJson(Map<String, dynamic> json) {
    return DesactivarDispositivoDataModel(
      idDispositivo: (json['id_dispositivo'] as num).toInt(),
      estadoDispositivo: json['estado_dispositivo'] as String,
      desactivado: json['desactivado'] as bool,
      yaEstabaDesactivado: json['ya_estaba_desactivado'] as bool,
    );
  }
}
