import 'persona_data_model.dart';
import 'rol_data_model.dart';

class UsuarioDataModel {
  final int idUsuario;
  final int idPersona;
  final String? emailAcceso;
  final String username;
  final bool estado;
  final DateTime? ultimoAcceso;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PersonaDataModel persona;
  final List<RolDataModel> roles;

  const UsuarioDataModel({
    required this.idUsuario,
    required this.idPersona,
    this.emailAcceso,
    required this.username,
    required this.estado,
    this.ultimoAcceso,
    this.createdAt,
    this.updatedAt,
    required this.persona,
    required this.roles,
  });

  // *********************************************************
  // 1. FROM JSON
  // *********************************************************
  factory UsuarioDataModel.fromJson(Map<String, dynamic> json) {
    return UsuarioDataModel(
      idUsuario: (json['id_usuario'] as num).toInt(),
      idPersona: (json['id_persona'] as num).toInt(),
      emailAcceso: json['email_acceso'] as String?,
      username: json['username'] as String,
      estado: json['estado'] as bool,
      ultimoAcceso: json['ultimo_acceso'] == null
          ? null
          : DateTime.parse(json['ultimo_acceso'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
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

  // *********************************************************
  // 2. TO JSON
  // *********************************************************
  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'id_persona': idPersona,
      'email_acceso': emailAcceso,
      'username': username,
      'estado': estado,
      'ultimo_acceso': ultimoAcceso?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'persona': persona.toJson(),
      'roles': roles.map((rol) => rol.toJson()).toList(),
    };
  }

  // *********************************************************
  // 3. GETTERS
  // *********************************************************
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
