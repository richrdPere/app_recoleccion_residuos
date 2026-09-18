// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_recoleccion_residuos/src/data/models/common/api_response.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/capacidad/capacidad_recorrido_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/detalle/recoleccion_detalle_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/evidencias/recoleccion_evidencia_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/evidencias/registrar_evidencia_req.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/progreso_recorrido/recorrido_progreso_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/puntos_recorrido/punto_recorrido_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion/registrar_recoleccion_req.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion_lote/registrar_recoleccion_lote_data_model.dart';
import 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion_lote/registrar_recoleccion_lote_req.dart';
import 'package:http/http.dart' as http;

// Environment
import 'package:app_recoleccion_residuos/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:app_recoleccion_residuos/src/data/datasources/remote/services/helpers/http_service_helper.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';
import 'package:http_parser/http_parser.dart';

// Models

class RecoleccionService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/recolecciones';

  String get API_REGISTER_RECOLECCION => '$API_BASE/register';
  String get API_REGISTRAR_RECOLECCION_LOTE => '$API_BASE/register-lote';
  String get API_GET_PUNTOS_RECORRIDO => '$API_BASE/recorridos';
  String get API_GET_RECORRIDO_PROGRESO => '$API_BASE/recorridos';
  String get API_POST_EVIDENCIA => '$API_BASE/evidencias';
  String get API_GET_RECORRIDO_BY_ID => '$API_BASE/view';
  String get API_GET_CAPACIDAD_RECORRIDOS => '$API_BASE/capacidad';

  // *********************************************************
  // 1. REGISTRAR RECOLECCIÓN
  // *********************************************************
  Future<Resource<ApiResponse<RegistrarRecoleccionDataModel>>>
  registrarRecoleccion({
    required RegistrarRecoleccionRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_REGISTER_RECOLECCION);

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

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<RegistrarRecoleccionDataModel>
        >(body, response.statusCode);
      }

      // 5. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RegistrarRecoleccionDataModel>>(
          message:
              'La respuesta del servidor no contiene una recolección válida.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA
      // Admite 201 para registro nuevo y 200 para duplicado.
      final apiResponse = ApiResponse<RegistrarRecoleccionDataModel>.fromJson(
        body,
        (rawData) => RegistrarRecoleccionDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RegistrarRecoleccionDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RegistrarRecoleccionDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Si reintentas el registro, conserva la misma clave de idempotencia.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RegistrarRecoleccionDataModel>>(
        message: 'Ocurrió un error al registrar la recolección.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. REGISTRAR LOTE DE RECOLECCIONES OFFLINE
  // *********************************************************
  Future<Resource<ApiResponse<RegistrarRecoleccionLoteDataModel>>>
  registrarRecoleccionLote({
    required RegistrarRecoleccionLoteRequest request,
    required String token,
  }) async {
    try {
      // 1. VALIDAR TAMAÑO DEL LOTE
      if (request.recolecciones.isEmpty) {
        return ErrorData<ApiResponse<RegistrarRecoleccionLoteDataModel>>(
          message: 'Debe enviar al menos una recolección.',
        );
      }

      if (request.recolecciones.length > 200) {
        return ErrorData<ApiResponse<RegistrarRecoleccionLoteDataModel>>(
          message: 'No se pueden enviar más de 200 recolecciones por lote.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse(API_REGISTRAR_RECOLECCION_LOTE);

      // 3. PETICIÓN HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<RegistrarRecoleccionLoteDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RegistrarRecoleccionLoteDataModel>>(
          message:
              'La respuesta del servidor no contiene un resultado de lote válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESULTADO
      // Los rechazos individuales se conservan dentro de resultados.
      final apiResponse =
          ApiResponse<RegistrarRecoleccionLoteDataModel>.fromJson(
            body,
            (rawData) => RegistrarRecoleccionLoteDataModel.fromJson(
              Map<String, dynamic>.from(rawData as Map),
            ),
          );

      return Success<ApiResponse<RegistrarRecoleccionLoteDataModel>>(
        apiResponse,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RegistrarRecoleccionLoteDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'El lote puede haberse procesado parcialmente. '
            'Conserva las claves de idempotencia al reintentar.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RegistrarRecoleccionLoteDataModel>>(
        message: 'Ocurrió un error al sincronizar las recolecciones.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER PUNTOS DEL RECORRIDO
  // *********************************************************
  Future<Resource<ApiResponse<List<PuntoRecorridoDataModel>>>>
  getPuntosRecorrido({required int idRecorrido, required String token}) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_GET_PUNTOS_RECORRIDO/idRecorrido/puntos');

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<List<PuntoRecorridoDataModel>>
        >(body, response.statusCode);
      }

      // 5. VALIDAR LISTADO
      // Un arreglo vacío es válido; null u otro tipo no lo son.
      if (body['data'] is! List) {
        return ErrorData<ApiResponse<List<PuntoRecorridoDataModel>>>(
          message:
              'La respuesta del servidor no contiene un listado de puntos válido.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<List<PuntoRecorridoDataModel>>.fromJson(
        body,
        (rawData) => (rawData as List)
            .map(
              (item) => PuntoRecorridoDataModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );

      return Success<ApiResponse<List<PuntoRecorridoDataModel>>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<List<PuntoRecorridoDataModel>>>(
        message:
            'El servidor tardó demasiado en responder al consultar los puntos.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<List<PuntoRecorridoDataModel>>>(
        message: 'Ocurrió un error al obtener los puntos del recorrido.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. OBTENER PROGRESO DEL RECORRIDO
  // *********************************************************
  Future<Resource<ApiResponse<RecorridoProgresoDataModel>>>
  getRecorridoProgreso({
    required int idRecorrido,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(
        '$API_GET_RECORRIDO_PROGRESO/$idRecorrido/progreso',
      );

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<RecorridoProgresoDataModel>
        >(body, response.statusCode);
      }

      // 5. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RecorridoProgresoDataModel>>(
          message: 'La respuesta del servidor no contiene un progreso válido.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<RecorridoProgresoDataModel>.fromJson(
        body,
        (rawData) => RecorridoProgresoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RecorridoProgresoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecorridoProgresoDataModel>>(
        message:
            'El servidor tardó demasiado en responder al consultar el progreso.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecorridoProgresoDataModel>>(
        message: 'Ocurrió un error al obtener el progreso del recorrido.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. REGISTRAR EVIDENCIA DE RECOLECCIÓN
  // *********************************************************
  Future<Resource<ApiResponse<RecoleccionEvidenciaDataModel>>>
  registrarEvidencia({
    required int idRecoleccion,
    required RegistrarEvidenciaRequest request,
    required String token,
  }) async {
    try {
      // 1. VALIDAR ARCHIVO LOCAL
      final file = File(request.archivoPath);

      if (!await file.exists()) {
        return ErrorData<ApiResponse<RecoleccionEvidenciaDataModel>>(
          message: 'El archivo seleccionado no existe.',
        );
      }

      final fileSize = await file.length();

      if (fileSize > 5 * 1024 * 1024) {
        return ErrorData<ApiResponse<RecoleccionEvidenciaDataModel>>(
          message: 'El archivo no puede superar los 5 MiB.',
        );
      }

      // 2. DETERMINAR MIME PARA LOS FORMATOS ADMITIDOS
      final extension = HttpServiceHelper.getExtension(request.archivoPath);

      const allowedMimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
        'pdf': 'application/pdf',
      };

      final mimeType = allowedMimeTypes[extension];

      if (mimeType == null) {
        return ErrorData<ApiResponse<RecoleccionEvidenciaDataModel>>(
          message: 'Selecciona un archivo JPG, PNG, WebP o PDF.',
        );
      }

      // 3. CONSTRUIR URL Y MULTIPART
      final uri = Uri.parse('$API_POST_EVIDENCIA/$idRecoleccion');

      final multipartRequest = http.MultipartRequest('POST', uri);

      // No establecer Content-Type manualmente:
      // MultipartRequest genera el boundary.
      multipartRequest.headers.addAll(
        HttpServiceHelper.getMultipartHeaders(token: token),
      );

      multipartRequest.fields.addAll(request.toFields());

      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          request.archivoPath,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // 4. ENVIAR Y LEER LA RESPUESTA COMPLETA
      final response = await (() async {
        final streamedResponse = await multipartRequest.send();

        return await http.Response.fromStream(streamedResponse);
      })().timeout(const Duration(seconds: 60));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<RecoleccionEvidenciaDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RecoleccionEvidenciaDataModel>>(
          message:
              'La respuesta del servidor no contiene una evidencia válida.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<RecoleccionEvidenciaDataModel>.fromJson(
        body,
        (rawData) => RecoleccionEvidenciaDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RecoleccionEvidenciaDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecoleccionEvidenciaDataModel>>(
        message:
            'La carga tardó demasiado en responder. '
            'Verifica si la evidencia fue registrada antes de volver a enviarla.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecoleccionEvidenciaDataModel>>(
        message: 'Ocurrió un error al registrar la evidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. OBTENER RECOLECCIÓN POR ID
  // *********************************************************
  Future<Resource<ApiResponse<RecoleccionDetalleDataModel>>>
  getRecoleccionById({
    required int idRecoleccion,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_GET_RECORRIDO_BY_ID/$idRecoleccion');

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<RecoleccionDetalleDataModel>
        >(body, response.statusCode);
      }

      // 5. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RecoleccionDetalleDataModel>>(
          message:
              'La respuesta del servidor no contiene una recolección válida.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<RecoleccionDetalleDataModel>.fromJson(
        body,
        (rawData) => RecoleccionDetalleDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RecoleccionDetalleDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RecoleccionDetalleDataModel>>(
        message:
            'El servidor tardó demasiado en responder al consultar la recolección.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RecoleccionDetalleDataModel>>(
        message: 'Ocurrió un error al obtener el detalle de la recolección.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 7. OBTENER CAPACIDAD DEL VEHÍCULO EN EL RECORRIDO
  // *********************************************************
  Future<Resource<ApiResponse<CapacidadRecorridoDataModel>>>
  getCapacidadRecorrido({
    required int idRecorrido,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_GET_CAPACIDAD_RECORRIDOS/$idRecorrido');

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<CapacidadRecorridoDataModel>
        >(body, response.statusCode);
      }

      // 5. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<CapacidadRecorridoDataModel>>(
          message:
              'La respuesta del servidor no contiene datos de capacidad válidos.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<CapacidadRecorridoDataModel>.fromJson(
        body,
        (rawData) => CapacidadRecorridoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<CapacidadRecorridoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<CapacidadRecorridoDataModel>>(
        message:
            'El servidor tardó demasiado en responder al consultar la capacidad.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<CapacidadRecorridoDataModel>>(
        message: 'Ocurrió un error al obtener la capacidad del vehículo.',
        error: error.toString(),
      );
    }
  }
}
