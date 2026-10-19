// *********************************************************
// DATA - DOMICILIO ELIMINADO
// *********************************************************

class DeleteCiudadanoDomicilioDataModel {
  final int idDomicilio;
  final bool eliminado;

  const DeleteCiudadanoDomicilioDataModel({
    required this.idDomicilio,
    required this.eliminado,
  });

  factory DeleteCiudadanoDomicilioDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawId = json['id_domicilio'];

    final int? id = rawId is int
        ? rawId
        : rawId is String
        ? int.tryParse(rawId)
        : null;

    if (id == null || id <= 0) {
      throw const FormatException(
        'El servidor devolvió un identificador de domicilio inválido.',
      );
    }

    return DeleteCiudadanoDomicilioDataModel(
      idDomicilio: id,
      eliminado: json['eliminado'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_domicilio': idDomicilio, 'eliminado': eliminado};
  }
}
