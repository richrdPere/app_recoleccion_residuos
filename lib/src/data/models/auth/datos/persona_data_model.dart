class PersonaDataModel {
  final int idPersona;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final String? fechaNacimiento;
  final String? celular;
  final String? direccion;
  final String? fotoUrl;
  final String? genero;
  final bool estado;

  const PersonaDataModel({
    required this.idPersona,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.numeroDocumento,
    this.fechaNacimiento,
    this.celular,
    this.direccion,
    this.fotoUrl,
    this.genero,
    required this.estado,
  });

  factory PersonaDataModel.fromJson(Map<String, dynamic> json) {
    return PersonaDataModel(
      idPersona: (json['id_persona'] as num).toInt(),
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      tipoDocumento: json['tipo_documento'] as String,
      numeroDocumento: json['numero_documento'] as String,
      fechaNacimiento: json['fecha_nacimiento'] as String?,
      celular: json['celular'] as String?,
      direccion: json['direccion'] as String?,
      fotoUrl: json['foto_url'] as String?,
      genero: json['genero'] as String?,
      estado: json['estado'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_persona': idPersona,
      'nombres': nombres,
      'apellidos': apellidos,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      'fecha_nacimiento': fechaNacimiento,
      'celular': celular,
      'direccion': direccion,
      'foto_url': fotoUrl,
      'genero': genero,
      'estado': estado,
    };
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();
}
