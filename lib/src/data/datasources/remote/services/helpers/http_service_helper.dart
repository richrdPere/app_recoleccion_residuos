import 'dart:convert';

import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;


class HttpServiceHelper {
  const HttpServiceHelper._();

  // ***********************************************************
  // 1. GET JSON HEADERS
  // ***********************************************************
  static Map<String, String> getHeaders({
    String? token,
    Map<String, String>? extraHeaders,
  }) {
    final normalizedToken = token?.trim();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',

      if (normalizedToken != null && normalizedToken.isNotEmpty)
        'Authorization': 'Bearer $normalizedToken',

      ...?extraHeaders,
    };
  }

  // ***********************************************************
  // 2. GET MULTIPART HEADERS
  // ***********************************************************
  static Map<String, String> getMultipartHeaders({
    String? token,
    Map<String, String>? extraHeaders,
  }) {
    final normalizedToken = token?.trim();

    /*
     * No se agrega Content-Type.
     *
     * MultipartRequest lo genera automáticamente junto
     * con el boundary necesario para procesar el formulario.
     */
    return {
      'Accept': 'application/json',

      if (normalizedToken != null && normalizedToken.isNotEmpty)
        'Authorization': 'Bearer $normalizedToken',

      ...?extraHeaders,
    };
  }

  // ***********************************************************
  // 3. DECODE RESPONSE
  // ***********************************************************
  static Map<String, dynamic> decodeResponse(http.Response response) {
    try {
      final rawBody = response.body.trim();

      if (rawBody.isEmpty) {
        return {
          'success': false,
          'message': 'El servidor devolvió una respuesta vacía.',
        };
      }

      final decoded = jsonDecode(rawBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {
        'success': false,
        'message': 'La respuesta del servidor no tiene un formato válido.',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'No se pudo interpretar la respuesta del servidor.',
        'error': error.toString(),
      };
    }
  }

  // ***********************************************************
  // 4. BUILD ERROR
  // ***********************************************************
  static ErrorData<T> buildError<T>(Map<String, dynamic> body, int statusCode) {
    final message = body['message']?.toString().trim();

    final error = body['error']?.toString().trim();

    return ErrorData<T>(
      message: message != null && message.isNotEmpty
          ? message
          : getDefaultErrorMessage(statusCode),
      error: error != null && error.isNotEmpty ? error : null,
      statusCode: statusCode,
    );
  }

  // ***********************************************************
  // 5. IS SUCCESS
  // ***********************************************************
  static bool isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // ***********************************************************
  // 6. GET DEFAULT ERROR MESSAGE
  // ***********************************************************
  static String getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Los datos enviados no son válidos.';

      case 401:
        return 'La sesión ha expirado o no está autorizada.';

      case 403:
        return 'No tienes permisos para realizar esta acción.';

      case 404:
        return 'No se encontró el recurso solicitado.';

      case 409:
        return 'Ya existe un registro con los datos enviados.';

      case 413:
        return 'El archivo enviado supera el tamaño permitido.';

      case 422:
        return 'No se pudieron procesar los datos enviados.';

      case 429:
        return 'Se realizaron demasiadas solicitudes. Inténtalo nuevamente.';

      case 500:
        return 'Ocurrió un error interno en el servidor.';

      case 502:
        return 'El servidor no pudo comunicarse con otro servicio.';

      case 503:
        return 'El servicio no se encuentra disponible temporalmente.';

      case 504:
        return 'El servidor tardó demasiado en responder.';

      default:
        return 'Ocurrió un error al procesar la solicitud.';
    }
  }

  // ***********************************************************
  // 7. GET FILE EXTENSION
  // ***********************************************************
  static String getExtension(String filePath) {
    final extension = path.extension(filePath);

    if (extension.isEmpty) {
      return '';
    }

    /*
     * path.extension devuelve, por ejemplo, ".jpg".
     * Se elimina el punto para retornar "jpg".
     */
    return extension.replaceFirst('.', '').trim().toLowerCase();
  }

  // ***********************************************************
  // 8. GET MEDIA TYPE
  // ***********************************************************
  static MediaType? getMediaType(String filePath) {
    final extension = getExtension(filePath);

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');

      case 'png':
        return MediaType('image', 'png');

      case 'heic':
        return MediaType('image', 'heic');

      case 'heif':
        return MediaType('image', 'heif');

      case 'mp4':
        return MediaType('video', 'mp4');

      case 'mov':
        return MediaType('video', 'quicktime');

      default:
        return null;
    }
  }

  // ***********************************************************
  // 9. IS ALLOWED MEDIA FILE
  // ***********************************************************
  static bool isAllowedMediaFile(String filePath) {
    return getMediaType(filePath) != null;
  }
}
