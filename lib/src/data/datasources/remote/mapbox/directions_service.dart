import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class DirectionsService {
  final http.Client client;
  final String mapBoxApiKey;

  DirectionsService(this.client, this.mapBoxApiKey);

  // *********************************************************
  // 1. CALCULAR RUTA
  // *********************************************************
  Future<Resource<RutaCalculadaEntity>> calcularRuta({
    required CoordenadaEntity origen,
    required CoordenadaEntity destino,
    List<CoordenadaEntity> puntosIntermedios = const [],
    PerfilDesplazamiento perfil = PerfilDesplazamiento.conduccion,
    bool incluirInstrucciones = false,
  }) async {
    if (mapBoxApiKey.trim().isEmpty) {
      return ErrorData(message: 'No se ha configurado el token de Mapbox.');
    }

    final puntos = [origen, ...puntosIntermedios, destino];

    if (puntos.length > 25) {
      return ErrorData(message: 'La ruta admite un máximo de 25 puntos.');
    }

    if (puntos.any((punto) => !_coordenadaValida(punto))) {
      return ErrorData(message: 'La ruta contiene coordenadas inválidas.');
    }

    try {
      // Mapbox recibe cada coordenada como longitud,latitud.
      final coordenadas = puntos
          .map((punto) => '${punto.longitud},${punto.latitud}')
          .join(';');

      final parametros = <String, String>{
        'access_token': mapBoxApiKey.trim(),
        'geometries': 'geojson',
        'overview': 'full',
        'alternatives': 'false',
        'steps': incluirInstrucciones.toString(),
      };

      if (incluirInstrucciones) {
        parametros['language'] = 'es';
      }

      final uri = Uri.https(
        'api.mapbox.com',
        '/directions/v5/mapbox/${_obtenerPerfil(perfil)}/$coordenadas',
        parametros,
      );

      final response = await client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return ErrorData(message: _mensajeHttp(response.statusCode));
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      final json = _objeto(decoded);

      if (json['code'] != 'Ok') {
        return ErrorData(message: _mensajeDirections(json['code']));
      }

      final rutas = _lista(json['routes']);

      if (rutas.isEmpty) {
        return ErrorData(
          message: 'No se encontraron rutas entre los puntos indicados.',
        );
      }

      final ruta = _convertirRuta(_objeto(rutas.first));

      return Success<RutaCalculadaEntity>(ruta);
    } on TimeoutException {
      return ErrorData(
        message: 'Se agotó el tiempo de espera al calcular la ruta.',
      );
    } on http.ClientException {
      return ErrorData(
        message: 'No se pudo conectar con Mapbox. Revisa tu conexión.',
      );
    } on FormatException {
      return ErrorData(
        message: 'La respuesta de Directions tiene un formato inválido.',
      );
    } catch (_) {
      return ErrorData(message: 'Ocurrió un error al calcular la ruta.');
    }
  }

  // *********************************************************
  // 2. CONVERTIR RUTA A ENTITY
  // *********************************************************
  RutaCalculadaEntity _convertirRuta(Map<String, dynamic> json) {
    final geometria = _objeto(json['geometry']);

    if (geometria['type'] != 'LineString') {
      throw const FormatException('Geometría inválida.');
    }

    final coordenadas = _lista(
      geometria['coordinates'],
    ).map(_convertirCoordenada).toList();

    if (coordenadas.length < 2) {
      throw const FormatException('Geometría incompleta.');
    }

    return RutaCalculadaEntity(
      geometria: coordenadas,
      distanciaMetros: _numero(json['distance']),
      duracionSegundos: _numero(json['duration']),
      tramos: _lista(
        json['legs'],
      ).map((item) => _convertirTramo(_objeto(item))).toList(),
    );
  }

  // *********************************************************
  // 3. CONVERTIR TRAMO A ENTITY
  // *********************************************************
  TramoRutaEntity _convertirTramo(Map<String, dynamic> json) {
    final pasos = json['steps'] == null ? <dynamic>[] : _lista(json['steps']);

    return TramoRutaEntity(
      distanciaMetros: _numero(json['distance']),
      duracionSegundos: _numero(json['duration']),
      resumen: _texto(json['summary']),
      pasos: pasos.map((item) => _convertirPaso(_objeto(item))).toList(),
    );
  }

  // *********************************************************
  // 4. CONVERTIR PASO A ENTITY
  // *********************************************************
  PasoRutaEntity _convertirPaso(Map<String, dynamic> json) {
    final maniobra = _objeto(json['maneuver']);
    final instruccion = _texto(maniobra['instruction']);

    if (instruccion == null) {
      throw const FormatException('Instrucción incompleta.');
    }

    return PasoRutaEntity(
      instruccion: instruccion,
      nombreVia: _texto(json['name']),
      ubicacionManiobra: _convertirCoordenada(maniobra['location']),
      distanciaMetros: _numero(json['distance']),
      duracionSegundos: _numero(json['duration']),
    );
  }

  // *********************************************************
  // 5. CONVERTIR COORDENADA
  // *********************************************************
  CoordenadaEntity _convertirCoordenada(dynamic valor) {
    final coordenadas = _lista(valor);

    if (coordenadas.length < 2) {
      throw const FormatException('Coordenada incompleta.');
    }

    final longitud = _numero(coordenadas[0]);
    final latitud = _numero(coordenadas[1]);

    if (latitud < -90 || latitud > 90 || longitud < -180 || longitud > 180) {
      throw const FormatException('Coordenada fuera de rango.');
    }

    return CoordenadaEntity(latitud: latitud, longitud: longitud);
  }

  // *********************************************************
  // 6. PERFIL DE DESPLAZAMIENTO
  // *********************************************************
  String _obtenerPerfil(PerfilDesplazamiento perfil) {
    switch (perfil) {
      case PerfilDesplazamiento.conduccion:
        return 'driving';
      case PerfilDesplazamiento.caminata:
        return 'walking';
      case PerfilDesplazamiento.bicicleta:
        return 'cycling';
    }
  }

  // *********************************************************
  // 7. VALIDACIÓN Y LECTURA DE DATOS
  // *********************************************************
  bool _coordenadaValida(CoordenadaEntity punto) {
    return punto.latitud.isFinite &&
        punto.longitud.isFinite &&
        punto.latitud >= -90 &&
        punto.latitud <= 90 &&
        punto.longitud >= -180 &&
        punto.longitud <= 180;
  }

  Map<String, dynamic> _objeto(dynamic valor) {
    if (valor is Map<String, dynamic>) {
      return valor;
    }

    throw const FormatException('Se esperaba un objeto JSON.');
  }

  List<dynamic> _lista(dynamic valor) {
    if (valor is List) {
      return valor;
    }

    throw const FormatException('Se esperaba una lista JSON.');
  }

  double _numero(dynamic valor) {
    if (valor is num && valor.isFinite && valor >= 0) {
      return valor.toDouble();
    }

    // Las coordenadas pueden ser negativas.
    if (valor is num && valor.isFinite) {
      return valor.toDouble();
    }

    throw const FormatException('Se esperaba un número válido.');
  }

  String? _texto(dynamic valor) {
    if (valor is! String || valor.trim().isEmpty) {
      return null;
    }

    return valor.trim();
  }

  // *********************************************************
  // 8. MENSAJES DE ERROR
  // *********************************************************
  String _mensajeHttp(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'El token de Mapbox no es válido.';
      case 403:
        return 'No tienes acceso al servicio Directions de Mapbox.';
      case 400:
      case 422:
        return 'Los parámetros enviados para calcular la ruta '
            'no son válidos.';
      case 429:
        return 'Se alcanzó el límite de consultas de Mapbox.';
      default:
        return 'No se pudo calcular la ruta '
            '(HTTP $statusCode).';
    }
  }

  String _mensajeDirections(dynamic codigo) {
    switch (codigo) {
      case 'NoRoute':
        return 'No existe un camino disponible entre los puntos.';
      case 'NoSegment':
        return 'No se encontró una vía cercana a uno de los puntos.';
      default:
        return 'Mapbox no pudo calcular la ruta solicitada.';
    }
  }
}
