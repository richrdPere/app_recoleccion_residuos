// *********************************************************
// REQUEST - REGISTRO DE CIUDADANO
// *********************************************************

class RegisterCiudadanoRequest {
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final String? celular;
  final String email;
  final String username;
  final String password;

  const RegisterCiudadanoRequest({
    required this.nombres,
    required this.apellidos,
    this.tipoDocumento = 'DNI',
    required this.numeroDocumento,
    this.celular,
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombres': nombres.trim(),
      'apellidos': apellidos.trim(),
      'tipo_documento': tipoDocumento.trim().toUpperCase(),
      'numero_documento': numeroDocumento.trim().toUpperCase(),
      'celular': celular?.trim(),
      'email': email.trim().toLowerCase(),
      'username': username.trim().toLowerCase(),

      // No aplicar trim ni modificar la contraseña.
      'password': password,
    };
  }
}

// *********************************************************
// DATA - REGISTRO DE CIUDADANO
// *********************************************************

class RegisterCiudadanoDataModel {
  final int idUsuario;
  final int idPersona;
  final String email;
  final String username;
  final bool estado;
  final RegisterCiudadanoPersonaModel persona;
  final List<RegisterCiudadanoRolModel> roles;

  const RegisterCiudadanoDataModel({
    required this.idUsuario,
    required this.idPersona,
    required this.email,
    required this.username,
    required this.estado,
    required this.persona,
    required this.roles,
  });

  factory RegisterCiudadanoDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterCiudadanoDataModel(
      idUsuario: _parseId(json['id_usuario']),
      idPersona: _parseId(json['id_persona']),
      email: json['email'] as String,
      username: json['username'] as String,
      estado: json['estado'] as bool,
      persona: RegisterCiudadanoPersonaModel.fromJson(
        Map<String, dynamic>.from(json['persona'] as Map),
      ),
      roles: (json['roles'] as List)
          .map(
            (item) => RegisterCiudadanoRolModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'id_persona': idPersona,
      'email': email,
      'username': username,
      'estado': estado,
      'persona': persona.toJson(),
      'roles': roles.map((rol) => rol.toJson()).toList(),
    };
  }
}

// *********************************************************
// PERSONA
// *********************************************************

class RegisterCiudadanoPersonaModel {
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

  const RegisterCiudadanoPersonaModel({
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

  String get nombreCompleto => '$nombres $apellidos'.trim();

  factory RegisterCiudadanoPersonaModel.fromJson(Map<String, dynamic> json) {
    return RegisterCiudadanoPersonaModel(
      idPersona: _parseId(json['id_persona']),
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
}

// *********************************************************
// ROL
// *********************************************************

class RegisterCiudadanoRolModel {
  final int idRol;
  final String nombre;
  final String? descripcion;

  const RegisterCiudadanoRolModel({
    required this.idRol,
    required this.nombre,
    this.descripcion,
  });

  factory RegisterCiudadanoRolModel.fromJson(Map<String, dynamic> json) {
    return RegisterCiudadanoRolModel(
      idRol: _parseId(json['id_rol']),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_rol': idRol, 'nombre': nombre, 'descripcion': descripcion};
  }
}

// *********************************************************
// CONVERSIÓN DE IDENTIFICADORES
// *********************************************************

int _parseId(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) {
      return parsed;
    }
  }

  throw const FormatException(
    'El servidor devolvió un identificador inválido.',
  );
}
