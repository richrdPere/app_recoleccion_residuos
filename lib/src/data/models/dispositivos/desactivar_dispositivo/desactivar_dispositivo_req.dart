// *********************************************************
// REQUEST
// *********************************************************
class DesactivarDispositivoRequest {
  final String? motivo;

  const DesactivarDispositivoRequest({this.motivo});

  Map<String, dynamic> toJson() {
    final motivoNormalizado = motivo?.trim();

    return {
      if (motivoNormalizado != null && motivoNormalizado.isNotEmpty)
        'motivo': motivoNormalizado,
    };
  }
}
