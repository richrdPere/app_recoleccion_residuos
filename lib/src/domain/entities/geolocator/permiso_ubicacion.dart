enum PermisoUbicacion {
  denegado,
  denegadoPermanentemente,
  duranteUso,
  siempre,
  desconocido,
}

extension PermisoUbicacionExtension on PermisoUbicacion {
  bool get permiteUbicacion {
    return this == PermisoUbicacion.duranteUso ||
        this == PermisoUbicacion.siempre;
  }

  bool get requiereConfiguracion {
    return this == PermisoUbicacion.denegadoPermanentemente;
  }
}
