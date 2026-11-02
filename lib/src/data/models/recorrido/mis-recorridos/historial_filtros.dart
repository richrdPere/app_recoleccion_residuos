class HistorialFiltros {
  final String search;
  final String? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  const HistorialFiltros({
    this.search = '',
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
  });

  int get cantidadFiltros =>
      (estado != null ? 1 : 0) +
      (fechaDesde != null ? 1 : 0) +
      (fechaHasta != null ? 1 : 0);

  bool get tieneBusqueda => search.trim().isNotEmpty;

  HistorialFiltros copyWith({
    String? search,
    String? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool limpiarEstado = false,
    bool limpiarFechaDesde = false,
    bool limpiarFechaHasta = false,
  }) {
    return HistorialFiltros(
      search: search ?? this.search,
      estado: limpiarEstado ? null : estado ?? this.estado,
      fechaDesde: limpiarFechaDesde ? null : fechaDesde ?? this.fechaDesde,
      fechaHasta: limpiarFechaHasta ? null : fechaHasta ?? this.fechaHasta,
    );
  }

  Map<String, String> toQueryParameters() {
    return {
      if (search.trim().isNotEmpty) 'search': search.trim(),

      if (estado != null) 'estado': estado!,

      if (fechaDesde != null) 'fecha_desde': fechaApi(fechaDesde!),

      if (fechaHasta != null) 'fecha_hasta': fechaApi(fechaHasta!),
    };
  }

  static String fechaApi(DateTime fecha) {
    String dos(int valor) => valor.toString().padLeft(2, '0');

    return '${fecha.year}-${dos(fecha.month)}-${dos(fecha.day)}';
  }

  @override
  bool operator ==(Object other) {
    return other is HistorialFiltros &&
        search == other.search &&
        estado == other.estado &&
        fechaDesde == other.fechaDesde &&
        fechaHasta == other.fechaHasta;
  }

  @override
  int get hashCode => Object.hash(search, estado, fechaDesde, fechaHasta);
}
