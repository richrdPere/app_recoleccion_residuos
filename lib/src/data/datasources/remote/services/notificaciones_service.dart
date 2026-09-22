// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:async';
import 'package:http/http.dart' as http;

// Environment
import 'package:app_recoleccion_residuos/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:app_recoleccion_residuos/src/data/datasources/remote/services/helpers/http_service_helper.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class NotificacionesService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/notificaciones';

  // Bandeja personal
  String get API_GET_MIS_NOTIFICACIONES => '$API_BASE/mis-notificaciones';
  String get API_GET_TOTAL_NO_LEIDAS => '$API_BASE/no-leidas/';
  String get API_MARK_NOTIFICATION_NO_LEIDAS => '$API_BASE/leer-todas';

  // Operaciones individuales
  String get API_GET_NOTIFICACION_BY_ID => '${this.API_BASE}/';
  String get API_READ_NOTIFICATION => '${this.API_BASE}/';
  String get API_ARCHIVED_NOTIFICATION => this.API_BASE;

  // *********************************************************
  // 1. OBTENER MIS NOTIFICACIONES
  // *********************************************************
  Future<Resource<ApiResponse<GetMisNotificacionesDataModel>>>
  getMisNotificaciones({
    required String token,
    GetMisNotificacionesRequest query = const GetMisNotificacionesRequest(),
  }) async {
    try {
      // 1. CONSTRUIR URL CON QUERY PARAMS
      final uri = Uri.parse(
        API_GET_MIS_NOTIFICACIONES,
      ).replace(queryParameters: query.toQueryParameters());

      // 2. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 3. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<GetMisNotificacionesDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<GetMisNotificacionesDataModel>>(
          message: 'La respuesta del servidor no contiene un listado válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<GetMisNotificacionesDataModel>.fromJson(
        body,
        (rawData) => GetMisNotificacionesDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<GetMisNotificacionesDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<GetMisNotificacionesDataModel>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<GetMisNotificacionesDataModel>>(
        message: 'Ocurrió un error al obtener tus notificaciones.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER TOTAL DE NOTIFICACIONES NO LEÍDAS
  // *********************************************************
  Future<Resource<ApiResponse<GetTotalNoLeidasDataModel>>> getTotalNoLeidas({
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_GET_TOTAL_NO_LEIDAS);

      // 2. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 3. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<GetTotalNoLeidasDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<GetTotalNoLeidasDataModel>>(
          message: 'La respuesta del servidor no contiene un contador válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<GetTotalNoLeidasDataModel>.fromJson(
        body,
        (rawData) => GetTotalNoLeidasDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<GetTotalNoLeidasDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<GetTotalNoLeidasDataModel>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<GetTotalNoLeidasDataModel>>(
        message:
            'Ocurrió un error al obtener el total de notificaciones no leídas.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER NOTIFICACIÓN POR ID
  // *********************************************************
  Future<Resource<ApiResponse<GetNotificacionByIdDataModel>>>
  getNotificacionById({required int id, required String token}) async {
    try {
      // 1. VALIDAR ID
      if (id <= 0) {
        return ErrorData<ApiResponse<GetNotificacionByIdDataModel>>(
          message: 'El identificador de la notificación no es válido.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse('$API_BASE/$id');

      // 3. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 4. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<GetNotificacionByIdDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<GetNotificacionByIdDataModel>>(
          message:
              'La respuesta del servidor no contiene una notificación válida.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<GetNotificacionByIdDataModel>.fromJson(
        body,
        (rawData) => GetNotificacionByIdDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<GetNotificacionByIdDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<GetNotificacionByIdDataModel>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<GetNotificacionByIdDataModel>>(
        message: 'Ocurrió un error al obtener la notificación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. MARCAR NOTIFICACIÓN COMO LEÍDA
  // *********************************************************
  Future<Resource<ApiResponse<MarcarNotificacionLeidaDataModel>>>
  marcarNotificacionLeida({required int id, required String token}) async {
    try {
      // 1. VALIDAR ID
      if (id <= 0) {
        return ErrorData<ApiResponse<MarcarNotificacionLeidaDataModel>>(
          message: 'El identificador de la notificación no es válido.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse('$API_BASE/$id/leer');

      // 3. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 4. PETICIÓN HTTP
      final response = await http
          .patch(uri, headers: headers, body: '{}')
          .timeout(const Duration(seconds: 30));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<MarcarNotificacionLeidaDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<MarcarNotificacionLeidaDataModel>>(
          message:
              'La respuesta del servidor no contiene una notificación válida.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA
      final apiResponse =
          ApiResponse<MarcarNotificacionLeidaDataModel>.fromJson(
            body,
            (rawData) => MarcarNotificacionLeidaDataModel.fromJson(
              Map<String, dynamic>.from(rawData as Map),
            ),
          );

      return Success<ApiResponse<MarcarNotificacionLeidaDataModel>>(
        apiResponse,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<MarcarNotificacionLeidaDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta la notificación para verificar si se marcó como leída.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<MarcarNotificacionLeidaDataModel>>(
        message: 'Ocurrió un error al marcar la notificación como leída.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. MARCAR TODAS LAS NOTIFICACIONES COMO LEÍDAS
  // *********************************************************
  Future<Resource<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>>
  marcarTodasNotificacionesLeidas({required String token}) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_MARK_NOTIFICATION_NO_LEIDAS);

      // 2. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 3. PETICIÓN HTTP
      final response = await http
          .patch(uri, headers: headers, body: '{}')
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<MarcarTodasNotificacionesLeidasDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>(
          message: 'La respuesta del servidor no contiene un resultado válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA
      final apiResponse =
          ApiResponse<MarcarTodasNotificacionesLeidasDataModel>.fromJson(
            body,
            (rawData) => MarcarTodasNotificacionesLeidasDataModel.fromJson(
              Map<String, dynamic>.from(rawData as Map),
            ),
          );

      return Success<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>(
        apiResponse,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta tus notificaciones para verificar su estado.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<MarcarTodasNotificacionesLeidasDataModel>>(
        message:
            'Ocurrió un error al marcar todas las notificaciones como leídas.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. ARCHIVAR NOTIFICACIÓN
  // *********************************************************
  Future<Resource<ApiResponse<ArchivarNotificacionDataModel>>>
  archivarNotificacion({required int id, required String token}) async {
    try {
      // 1. VALIDAR ID
      if (id <= 0) {
        return ErrorData<ApiResponse<ArchivarNotificacionDataModel>>(
          message: 'El identificador de la notificación no es válido.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse('$API_ARCHIVED_NOTIFICATION/$id/archivar');

      // 3. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 4. PETICIÓN HTTP
      final response = await http
          .patch(uri, headers: headers, body: '{}')
          .timeout(const Duration(seconds: 30));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<ArchivarNotificacionDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<ArchivarNotificacionDataModel>>(
          message:
              'La respuesta del servidor no contiene una notificación válida.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<ArchivarNotificacionDataModel>.fromJson(
        body,
        (rawData) => ArchivarNotificacionDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<ArchivarNotificacionDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<ArchivarNotificacionDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta la notificación para verificar si se archivó.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<ArchivarNotificacionDataModel>>(
        message: 'Ocurrió un error al archivar la notificación.',
        error: error.toString(),
      );
    }
  }
}
