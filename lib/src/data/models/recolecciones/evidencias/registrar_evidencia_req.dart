class RegistrarEvidenciaRequest {
  final String archivoPath;
  final String? descripcion;
  final DateTime? fechaCaptura;

  const RegistrarEvidenciaRequest({
    required this.archivoPath,
    this.descripcion,
    this.fechaCaptura,
  });

  // Campos de texto del multipart.
  // El archivo se adjunta por separado.
  Map<String, String> toFields() {
    return {
      if (descripcion != null) 'descripcion': descripcion!,
      if (fechaCaptura != null)
        'fecha_captura': fechaCaptura!.toUtc().toIso8601String(),
    };
  }
}
