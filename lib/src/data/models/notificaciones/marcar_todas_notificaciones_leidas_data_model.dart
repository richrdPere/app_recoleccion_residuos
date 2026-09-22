// *********************************************************
// RESULTADO DE MARCAR TODAS COMO LEÍDAS
// *********************************************************
class MarcarTodasNotificacionesLeidasDataModel {
  final int actualizadas;

  const MarcarTodasNotificacionesLeidasDataModel({required this.actualizadas});

  factory MarcarTodasNotificacionesLeidasDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MarcarTodasNotificacionesLeidasDataModel(
      actualizadas: (json['actualizadas'] as num).toInt(),
    );
  }
}
