// *********************************************************
// REQUEST - RESOLVER COBERTURA
// *********************************************************

class ResolverCoberturaRequest {
  final double latitud;
  final double longitud;

  const ResolverCoberturaRequest({
    required this.latitud,
    required this.longitud,
  });

  Map<String, dynamic> toJson() {
    return {'latitud': latitud, 'longitud': longitud};
  }
}

// *********************************************************
// DATA - COBERTURA
// *********************************************************

class ResolverCoberturaDataModel {
  final double latitud;
  final double longitud;

  final bool tieneCobertura;
  final bool requiereSeleccionZona;

  final int? idZonaSugerida;

  final List<CoberturaZonaModel> zonas;

  const ResolverCoberturaDataModel({
    required this.latitud,
    required this.longitud,
    required this.tieneCobertura,
    required this.requiereSeleccionZona,
    this.idZonaSugerida,
    required this.zonas,
  });

  factory ResolverCoberturaDataModel.fromJson(Map<String, dynamic> json) {
    return ResolverCoberturaDataModel(
      latitud: _coberturaDouble(json['latitud']),
      longitud: _coberturaDouble(json['longitud']),

      tieneCobertura: json['tiene_cobertura'] as bool,

      requiereSeleccionZona: json['requiere_seleccion_zona'] as bool,

      idZonaSugerida: json['id_zona_sugerida'] == null
          ? null
          : _coberturaInt(json['id_zona_sugerida']),

      zonas: (json['zonas'] as List)
          .map(
            (item) => CoberturaZonaModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'tiene_cobertura': tieneCobertura,
      'requiere_seleccion_zona': requiereSeleccionZona,
      'id_zona_sugerida': idZonaSugerida,
      'zonas': zonas.map((item) => item.toJson()).toList(),
    };
  }
}

// *********************************************************
// ZONA CANDIDATA
// *********************************************************

class CoberturaZonaModel {
  final int idZona;

  final String codigo;
  final String nombre;
  final String color;

  final List<CoberturaRutaModel> rutas;

  const CoberturaZonaModel({
    required this.idZona,
    required this.codigo,
    required this.nombre,
    required this.color,
    required this.rutas,
  });

  factory CoberturaZonaModel.fromJson(Map<String, dynamic> json) {
    return CoberturaZonaModel(
      idZona: _coberturaInt(json['id_zona']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      color: json['color'] as String,

      rutas: (json['rutas'] as List)
          .map(
            (item) => CoberturaRutaModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_zona': idZona,
      'codigo': codigo,
      'nombre': nombre,
      'color': color,
      'rutas': rutas.map((item) => item.toJson()).toList(),
    };
  }
}

// *********************************************************
// RUTA CANDIDATA
// *********************************************************

class CoberturaRutaModel {
  final int idRuta;
  final int idZona;

  final String codigo;
  final String nombre;

  const CoberturaRutaModel({
    required this.idRuta,
    required this.idZona,
    required this.codigo,
    required this.nombre,
  });

  factory CoberturaRutaModel.fromJson(Map<String, dynamic> json) {
    return CoberturaRutaModel(
      idRuta: _coberturaInt(json['id_ruta']),
      idZona: _coberturaInt(json['id_zona']),
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ruta': idRuta,
      'id_zona': idZona,
      'codigo': codigo,
      'nombre': nombre,
    };
  }
}

// *********************************************************
// HELPERS DE CONVERSIÓN
// *********************************************************

int _coberturaInt(dynamic value) {
  if (value is int) return value;

  if (value is String) {
    final parsed = int.tryParse(value);

    if (parsed != null) return parsed;
  }

  throw const FormatException(
    'El servidor devolvió un identificador inválido.',
  );
}

double _coberturaDouble(dynamic value) {
  final double? parsed;

  if (value is num) {
    parsed = value.toDouble();
  } else if (value is String) {
    parsed = double.tryParse(value);
  } else {
    parsed = null;
  }

  if (parsed == null || !parsed.isFinite) {
    throw const FormatException(
      'El servidor devolvió una coordenada inválida.',
    );
  }

  return parsed;
}
