import 'persona_data_model.dart';
import 'rol_data_model.dart';

class UsuarioDataModel {
  final int idUsuario;
  final int idPersona;
  final String username;
  final bool estado;
  final DateTime? ultimoAcceso;
  final PersonaDataModel persona;
  final List<RolDataModel> roles;

  const UsuarioDataModel({
    required this.idUsuario,
    required this.idPersona,
    required this.username,
    required this.estado,
    this.ultimoAcceso,
    required this.persona,
    required this.roles,
  });

  factory UsuarioDataModel.fromJson(Map<String, dynamic> json) {
    return UsuarioDataModel(
      idUsuario: (json['id_usuario'] as num).toInt(),
      idPersona: (json['id_persona'] as num).toInt(),
      username: json['username'] as String,
      estado: json['estado'] as bool,
      ultimoAcceso: json['ultimo_acceso'] == null
          ? null
          : DateTime.parse(json['ultimo_acceso'] as String),
      persona: PersonaDataModel.fromJson(
        Map<String, dynamic>.from(json['persona'] as Map),
      ),
      roles: List<RolDataModel>.unmodifiable(
        (json['roles'] as List).map(
          (item) =>
              RolDataModel.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'id_persona': idPersona,
      'username': username,
      'estado': estado,
      'ultimo_acceso': ultimoAcceso?.toIso8601String(),
      'persona': persona.toJson(),
      'roles': roles.map((rol) => rol.toJson()).toList(),
    };
  }

  String get nombreCompleto => persona.nombreCompleto;

  List<String> get nombresRoles =>
      roles.map((rol) => rol.nombre).toList(growable: false);

  bool tieneRol(String nombre) {
    final normalizedNombre = nombre.trim().toUpperCase();

    return roles.any((rol) => rol.nombre.toUpperCase() == normalizedNombre);
  }

  bool get esConductor => tieneRol('CONDUCTOR');

  bool get esRecolector => tieneRol('RECOLECTOR');
}
