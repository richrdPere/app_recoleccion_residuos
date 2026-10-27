import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class GeocodingService {
  final http.Client client;
  final String mapBoxApiKey;

  /// Activar únicamente si tu cuenta permite almacenar
  /// permanentemente los resultados de geocodificación.
  final bool almacenamientoPermanente;

  GeocodingService(
    this.client,
    this.mapBoxApiKey, {
    this.almacenamientoPermanente = false,
  });

  // *********************************************************
  // 1. BUSCAR DIRECCIÓN
  // *********************************************************
  Future<Resource<List<DireccionGeograficaEntity>>> buscarDireccion({
    required String texto,
    CoordenadaEntity? proximidad,
    LimitesGeograficosEntity? limites,
    String codigoPais = 'pe',
    int limite = 5,
  }) async {
    final consulta = texto.trim();
    final pais = codigoPais.trim().toLowerCase();

    if (consulta.isEmpty) {
      return ErrorData(
        message: 'Ingresa una dirección para realizar la búsqueda.',
      );
    }

    if (limite < 1 || limite > 10) {
      return ErrorData(
        message: 'El límite de resultados debe estar entre 1 y 10.',
      );
    }

    if (!RegExp(r'^[a-z]{2}$').hasMatch(pais)) {
      return ErrorData(message: 'El código de país debe contener dos letras.');
    }

    if (proximidad != null &&
        !_coordenadaValida(proximidad.latitud, proximidad.longitud)) {
      return ErrorData(
        message: 'Las coordenadas de proximidad no son válidas.',
      );
    }

    if (limites != null && !_limitesValidos(limites)) {
      return ErrorData(message: 'Los límites geográficos no son válidos.');
    }

    final parametros = <String, String>{
      'q': consulta,
      'country': pais,
      'language': 'es',
      'limit': limite.toString(),
      'autocomplete': 'false',
      'permanent': almacenamientoPermanente.toString(),
    };

    if (proximidad != null) {
      // Mapbox: longitud,latitud.
      parametros['proximity'] = '${proximidad.longitud},${proximidad.latitud}';
    }

    if (limites != null) {
      parametros['bbox'] = [
        limites.oeste,
        limites.sur,
        limites.este,
        limites.norte,
      ].join(',');
    }

    return await _consultar(
      path: '/search/geocode/v6/forward',
      parametros: parametros,
    );
  }

  // *********************************************************
  // 2. OBTENER DIRECCIÓN POR COORDENADAS
  // *********************************************************
  Future<Resource<List<DireccionGeograficaEntity>>> obtenerDireccion({
    required CoordenadaEntity coordenada,
  }) async {
    if (!_coordenadaValida(coordenada.latitud, coordenada.longitud)) {
      return ErrorData(message: 'Las coordenadas no son válidas.');
    }

    return await _consultar(
      path: '/search/geocode/v6/reverse',
      parametros: {
        'longitude': coordenada.longitud.toString(),
        'latitude': coordenada.latitud.toString(),
        'language': 'es',
        'permanent': almacenamientoPermanente.toString(),
      },
    );
  }

  // *********************************************************
  // 3. EJECUTAR CONSULTA HTTP
  // *********************************************************
  Future<Resource<List<DireccionGeograficaEntity>>> _consultar({
    required String path,
    required Map<String, String> parametros,
  }) async {
    if (mapBoxApiKey.trim().isEmpty) {
      return ErrorData(message: 'No se ha configurado el token de Mapbox.');
    }

    try {
      final uri = Uri.https('api.mapbox.com', path, {
        ...parametros,
        'access_token': mapBoxApiKey.trim(),
      });

      final response = await client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return ErrorData(
          message: _mensajeHttp(response.statusCode),
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      final json = _objeto(decoded);
      final features = json['features'];

      if (features is! List) {
        throw const FormatException('No se encontró una lista de resultados.');
      }

      final direcciones = features
          .map((feature) => _convertirDireccion(_objeto(feature)))
          .toList();

      // Una lista vacía es una búsqueda válida sin coincidencias.
      return Success<List<DireccionGeograficaEntity>>(direcciones);
    } on TimeoutException {
      return ErrorData(
        message: 'Se agotó el tiempo de espera al consultar la dirección.',
      );
    } on http.ClientException {
      return ErrorData(
        message: 'No se pudo conectar con Mapbox. Revisa tu conexión.',
      );
    } on FormatException {
      return ErrorData(
        message: 'La respuesta de Geocoding tiene un formato inválido.',
      );
    } catch (_) {
      return ErrorData(message: 'Ocurrió un error al consultar la dirección.');
    }
  }

  // *********************************************************
  // 4. CONVERTIR RESULTADO A ENTITY
  // *********************************************************
  DireccionGeograficaEntity _convertirDireccion(Map<String, dynamic> feature) {
    final properties = _objeto(feature['properties']);
    final geometry = _objeto(feature['geometry']);

    if (geometry['type'] != 'Point') {
      throw const FormatException('La geometría del resultado no es un punto.');
    }

    final coordenadas = geometry['coordinates'];

    if (coordenadas is! List || coordenadas.length < 2) {
      throw const FormatException('Coordenadas incompletas.');
    }

    // GeoJSON: [longitud, latitud].
    final longitud = _numero(coordenadas[0]);
    final latitud = _numero(coordenadas[1]);

    if (!_coordenadaValida(latitud, longitud)) {
      throw const FormatException('Coordenadas fuera de rango.');
    }

    final context = properties['context'] == null
        ? <String, dynamic>{}
        : _objeto(properties['context']);

    final nombre =
        _texto(properties['name_preferred']) ?? _texto(properties['name']);

    final lugar = _texto(properties['place_formatted']);

    final direccion =
        _texto(properties['full_address']) ??
        [if (nombre != null) nombre, if (lugar != null) lugar].join(', ');

    if (direccion.isEmpty) {
      throw const FormatException('El resultado no contiene una dirección.');
    }

    return DireccionGeograficaEntity(
      direccionFormateada: direccion,
      coordenada: CoordenadaEntity(latitud: latitud, longitud: longitud),
      nombre: nombre,
      numero: _campoContexto(context, 'address', 'address_number'),
      via:
          _campoContexto(context, 'street', 'name') ??
          _campoContexto(context, 'address', 'street_name'),
      departamento: _campoContexto(context, 'region', 'name'),
      pais: _campoContexto(context, 'country', 'name'),
      codigoPais: _campoContexto(
        context,
        'country',
        'country_code',
      )?.toLowerCase(),
      codigoPostal: _campoContexto(context, 'postcode', 'name'),

      // Requieren una correspondencia validada con el ubigeo.
      provincia: null,
      distrito: null,
    );
  }

  // *********************************************************
  // 5. LEER DATOS DEL CONTEXTO GEOGRÁFICO
  // *********************************************************
  String? _campoContexto(
    Map<String, dynamic> context,
    String nivel,
    String campo,
  ) {
    final valor = context[nivel];

    if (valor == null) {
      return null;
    }

    return _texto(_objeto(valor)[campo]);
  }

  // *********************************************************
  // 6. VALIDACIONES
  // *********************************************************
  bool _coordenadaValida(double latitud, double longitud) {
    return latitud.isFinite &&
        longitud.isFinite &&
        latitud >= -90 &&
        latitud <= 90 &&
        longitud >= -180 &&
        longitud <= 180;
  }

  bool _limitesValidos(LimitesGeograficosEntity limites) {
    return _coordenadaValida(limites.sur, limites.oeste) &&
        _coordenadaValida(limites.norte, limites.este) &&
        limites.oeste < limites.este &&
        limites.sur < limites.norte;
  }

  // *********************************************************
  // 7. LECTURA SEGURA DE JSON
  // *********************************************************
  Map<String, dynamic> _objeto(dynamic valor) {
    if (valor is Map<String, dynamic>) {
      return valor;
    }

    throw const FormatException('Se esperaba un objeto JSON.');
  }

  double _numero(dynamic valor) {
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
  // 8. MENSAJES DE ERROR HTTP
  // *********************************************************
  String _mensajeHttp(int statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return 'Los parámetros enviados para buscar la dirección '
            'no son válidos.';
      case 401:
        return 'El token de Mapbox no es válido.';
      case 403:
        return 'No tienes acceso al servicio Geocoding de Mapbox.';
      case 429:
        return 'Se alcanzó el límite de consultas de Mapbox.';
      default:
        return 'No se pudo consultar la dirección '
            '(HTTP $statusCode).';
    }
  }
}
