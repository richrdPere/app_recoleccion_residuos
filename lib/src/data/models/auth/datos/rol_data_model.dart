class RolDataModel {
  final int idRol;
  final String nombre;
  final String? descripcion;

  const RolDataModel({
    required this.idRol,
    required this.nombre,
    this.descripcion,
  });

  factory RolDataModel.fromJson(Map<String, dynamic> json) {
    return RolDataModel(
      idRol: (json['id_rol'] as num).toInt(),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_rol': idRol, 'nombre': nombre, 'descripcion': descripcion};
  }
}
