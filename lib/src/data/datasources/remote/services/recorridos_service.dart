// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Environment
import 'package:app_recoleccion_residuos/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:app_recoleccion_residuos/src/data/datasources/remote/services/helpers/http_service_helper.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Models
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class RecorridoService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/recorridos';

  String get API_INICIAR_RECORRIDO => '$API_BASE/iniciar';
  String get API_PAUSAR_RECORRICO => '$API_BASE/pausar';
  String get API_REANUDAR_RECORRICO => '$API_BASE/reanudar';
  String get API_FINALIZAR_RECORRICO => '$API_BASE/finalizar';
  String get API_GET_RECORRIDO_ACTIVO => '$API_BASE/activo';
  String get API_GET_MIS_RECORRIDOS => '$API_BASE/mis-recorridos';
  String get API_GET_RECORRIDO_DETALLE => '$API_BASE/view';

  // *********************************************************
  // 1. INICIAR RECORRIDO
  // *********************************************************
  Future<Resource<ApiResponse<RecorridoDataModel>>> iniciarRecorrido({
    required int idProgramacion,
    required IniciarRecorridoRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_INICIAR_RECORRIDO/$idProgramacion');

      // 2. PETICIÓN HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] == true) {
        final apiResponse = ApiResponse<RecorridoDataModel>.fromJson(
          body,
          (rawData) => RecorridoDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<RecorridoDataModel>>(apiResponse);
      }

      // 5. VALIDAR DATOS DEL RECORRIDO
      return HttpServiceHelper.buildError<ApiResponse<RecorridoDataModel>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message: 'Ocurrió un error al iniciar el recorrido.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. PAUSAR RECORRIDO
  // *********************************************************
  Future<Resource<ApiResponse<RecorridoDataModel>>> pausarRecorrido({
    required int idRecorrido,
    required PausarRecorridoRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_PAUSAR_RECORRICO/$idRecorrido');

      // 2. PETICIÓN HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(
              token: token,
              extraHeaders: {'x-client-origin': 'APP'},
            ),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<ApiResponse<RecorridoDataModel>>(
          body,
          response.statusCode,
        );
      }

      // 5. VALIDAR DATOS DEL RECORRIDO
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RecorridoDataModel>>(
          message: 'La respuesta del servidor no contiene un recorrido válido.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<RecorridoDataModel>.fromJson(
        body,
        (rawData) => RecorridoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RecorridoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta el estado del recorrido antes de intentar una nueva pausa.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message: 'Ocurrió un error al pausar el recorrido.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. REANUDAR RECORRIDO
  // *********************************************************
  Future<Resource<ApiResponse<RecorridoDataModel>>> reanudarRecorrido({
    required int idRecorrido,
    required ReanudarRecorridoRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_REANUDAR_RECORRICO/$idRecorrido');

      // 2. PETICIÓN HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(
              token: token,
              extraHeaders: {'x-client-origin': 'APP'},
            ),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<ApiResponse<RecorridoDataModel>>(
          body,
          response.statusCode,
        );
      }

      // 5. VALIDAR DATOS DEL RECORRIDO
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RecorridoDataModel>>(
          message: 'La respuesta del servidor no contiene un recorrido válido.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<RecorridoDataModel>.fromJson(
        body,
        (rawData) => RecorridoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RecorridoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta el estado del recorrido antes de intentar reanudarlo nuevamente.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message: 'Ocurrió un error al reanudar el recorrido.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. FINALIZAR RECORRIDO
  // *********************************************************
  Future<Resource<ApiResponse<RecorridoDataModel>>> finalizarRecorrido({
    required int idRecorrido,
    required FinalizarRecorridoRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_FINALIZAR_RECORRICO/$idRecorrido');

      // 2. PETICIÓN HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(
              token: token,
              extraHeaders: {'x-client-origin': 'APP'},
            ),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<ApiResponse<RecorridoDataModel>>(
          body,
          response.statusCode,
        );
      }

      // 5. VALIDAR DATOS DEL RECORRIDO
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RecorridoDataModel>>(
          message: 'La respuesta del servidor no contiene un recorrido válido.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<RecorridoDataModel>.fromJson(
        body,
        (rawData) => RecorridoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RecorridoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta el estado del recorrido antes de intentar finalizarlo nuevamente.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message: 'Ocurrió un error al finalizar el recorrido.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. OBTENER RECORRIDO ACTIVO
  // *********************************************************
  Future<Resource<ApiResponse<RecorridoDataModel?>>> getRecorridoActivo({
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_GET_RECORRIDO_ACTIVO);

      // 2. PETICIÓN HTTP
      final response = await http
          .get(
            uri,
            headers: HttpServiceHelper.getHeaders(
              token: token,
              extraHeaders: {'x-client-origin': 'APP'},
            ),
          )
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<ApiResponse<RecorridoDataModel?>>(
          body,
          response.statusCode,
        );
      }

      // 5. VALIDAR DATA
      // Se admite un objeto o null, pero no un campo ausente.
      final rawData = body['data'];

      if (!body.containsKey('data') || (rawData != null && rawData is! Map)) {
        return ErrorData<ApiResponse<RecorridoDataModel?>>(
          message:
              'La respuesta del servidor no contiene datos válidos del recorrido.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<RecorridoDataModel?>.fromJson(body, (
        rawData,
      ) {
        if (rawData == null) return null;

        return RecorridoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        );
      });

      return Success<ApiResponse<RecorridoDataModel?>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel?>>(
        message:
            'El servidor tardó demasiado en responder al consultar el recorrido activo.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel?>>(
        message: 'Ocurrió un error al obtener el recorrido activo.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. OBTENER MIS RECORRIDOS PAGINADOS
  // *********************************************************
  Future<Resource<ApiResponse<MisRecorridosDataModel>>> getMisRecorridos({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // 1. VALIDAR PAGINACIÓN
      if (page < 1 || limit < 1) {
        return ErrorData<ApiResponse<MisRecorridosDataModel>>(
          message: 'La página y el límite deben ser mayores que cero.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse(API_GET_MIS_RECORRIDOS).replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      // 3. PETICIÓN HTTP
      final response = await http
          .get(
            uri,
            headers: HttpServiceHelper.getHeaders(
              token: token,
              extraHeaders: {'x-client-origin': 'APP'},
            ),
          )
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<MisRecorridosDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<MisRecorridosDataModel>>(
          message:
              'La respuesta del servidor no contiene un listado de recorridos válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<MisRecorridosDataModel>.fromJson(
        body,
        (rawData) => MisRecorridosDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<MisRecorridosDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<MisRecorridosDataModel>>(
        message:
            'El servidor tardó demasiado en responder al consultar tus recorridos.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<MisRecorridosDataModel>>(
        message: 'Ocurrió un error al obtener tus recorridos.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 7. OBTENER RECORRIDO POR ID
  // *********************************************************
  Future<Resource<ApiResponse<RecorridoDataModel>>> getRecorridoById({
    required int idRecorrido,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_GET_RECORRIDO_DETALLE/$idRecorrido');

      // 2. PETICIÓN HTTP
      final response = await http
          .get(
            uri,
            headers: HttpServiceHelper.getHeaders(
              token: token,
              extraHeaders: {'x-client-origin': 'APP'},
            ),
          )
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<ApiResponse<RecorridoDataModel>>(
          body,
          response.statusCode,
        );
      }

      // 5. VALIDAR DATOS DEL RECORRIDO
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RecorridoDataModel>>(
          message: 'La respuesta del servidor no contiene un recorrido válido.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<RecorridoDataModel>.fromJson(
        body,
        (rawData) => RecorridoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RecorridoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message:
            'El servidor tardó demasiado en responder al consultar el recorrido.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecorridoDataModel>>(
        message: 'Ocurrió un error al obtener el detalle del recorrido.',
        error: error.toString(),
      );
    }
  }
}
