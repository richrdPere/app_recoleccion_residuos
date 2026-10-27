class CoordenadaEntity {
  final double latitud;
  final double longitud;

  const CoordenadaEntity({required this.latitud, required this.longitud})
    : assert(
        latitud >= -90 && latitud <= 90,
        'La latitud debe estar entre -90 y 90.',
      ),
      assert(
        longitud >= -180 && longitud <= 180,
        'La longitud debe estar entre -180 y 180.',
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CoordenadaEntity &&
            latitud == other.latitud &&
            longitud == other.longitud;
  }

  @override
  int get hashCode => Object.hash(latitud, longitud);
}
