import '../geografia/coordenada_entity.dart';

class DireccionGeograficaEntity {
  final String direccionFormateada;
  final CoordenadaEntity coordenada;

  final String? nombre;
  final String? numero;
  final String? via;
  final String? distrito;
  final String? provincia;
  final String? departamento;
  final String? pais;
  final String? codigoPais;
  final String? codigoPostal;

  const DireccionGeograficaEntity({
    required this.direccionFormateada,
    required this.coordenada,
    this.nombre,
    this.numero,
    this.via,
    this.distrito,
    this.provincia,
    this.departamento,
    this.pais,
    this.codigoPais,
    this.codigoPostal,
  });
}
