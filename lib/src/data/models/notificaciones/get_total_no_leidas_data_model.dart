// *********************************************************
// TOTAL DE NOTIFICACIONES NO LEÍDAS
// *********************************************************
class GetTotalNoLeidasDataModel {
  final int totalNoLeidas;

  const GetTotalNoLeidasDataModel({required this.totalNoLeidas});

  factory GetTotalNoLeidasDataModel.fromJson(Map<String, dynamic> json) {
    return GetTotalNoLeidasDataModel(
      totalNoLeidas: (json['total_no_leidas'] as num).toInt(),
    );
  }
}
