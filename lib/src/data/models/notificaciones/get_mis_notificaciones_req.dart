class GetMisNotificacionesRequest {
  final int page;
  final int limit;
  final bool? leida;
  final bool archivada;
  final String? tipoNotificacion;
  final String? prioridad;
  final String? search;

  const GetMisNotificacionesRequest({
    this.page = 1,
    this.limit = 20,
    this.leida,
    this.archivada = false,
    this.tipoNotificacion,
    this.prioridad,
    this.search,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'archivada': archivada.toString(),
    };

    if (leida != null) {
      params['leida'] = leida.toString();
    }

    final tipo = tipoNotificacion?.trim();

    if (tipo != null && tipo.isNotEmpty) {
      params['tipo_notificacion'] = tipo;
    }

    final prioridadValue = prioridad?.trim();

    if (prioridadValue != null && prioridadValue.isNotEmpty) {
      params['prioridad'] = prioridadValue;
    }

    final searchValue = search?.trim();

    if (searchValue != null && searchValue.isNotEmpty) {
      params['search'] = searchValue;
    }

    return params;
  }
}
