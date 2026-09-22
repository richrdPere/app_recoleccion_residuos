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

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class TrackingService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/tracking';

  String get API_REGISTRAR_UBICACION => '$API_BASE/ubicaciones';
  String get API_REGISTRAR_UBICACION_LOTE => '$API_BASE/ubicaciones/lote';

  // *********************************************************
  // 1. REGISTRAR UBICACIÓN
  // *********************************************************
  Future<Resource<ApiResponse<RegistrarUbicacionDataModel>>>
  registrarUbicacion({
    required RegistrarUbicacionRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_REGISTRAR_UBICACION);

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
          ApiResponse<RegistrarUbicacionDataModel>
        >(body, response.statusCode);
      }

      // 5. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RegistrarUbicacionDataModel>>(
          message:
              'La respuesta del servidor no contiene una ubicación válida.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<RegistrarUbicacionDataModel>.fromJson(
        body,
        (rawData) => RegistrarUbicacionDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RegistrarUbicacionDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RegistrarUbicacionDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Conserva la ubicación y su clave de idempotencia para reintentar.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RegistrarUbicacionDataModel>>(
        message: 'Ocurrió un error al registrar la ubicación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. REGISTRAR UBICACIONES POR LOTE
  // *********************************************************
  Future<Resource<ApiResponse<RegistrarUbicacionLoteDataModel>>>
  registrarUbicacionLote({
    required RegistrarUbicacionLoteRequest request,
    required String token,
  }) async {
    try {
      // 1. VALIDAR REQUEST
      if (request.idRecorrido <= 0) {
        return ErrorData<ApiResponse<RegistrarUbicacionLoteDataModel>>(
          message: 'El identificador del recorrido no es válido.',
        );
      }

      if (request.ubicaciones.isEmpty) {
        return ErrorData<ApiResponse<RegistrarUbicacionLoteDataModel>>(
          message: 'Debe enviar al menos una ubicación.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse(API_REGISTRAR_UBICACION_LOTE);

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
          ApiResponse<RegistrarUbicacionLoteDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RegistrarUbicacionLoteDataModel>>(
          message:
              'La respuesta del servidor no contiene un resultado de lote válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA
      // Los rechazos individuales permanecen en "resultados".
      final apiResponse = ApiResponse<RegistrarUbicacionLoteDataModel>.fromJson(
        body,
        (rawData) => RegistrarUbicacionLoteDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RegistrarUbicacionLoteDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RegistrarUbicacionLoteDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'El lote puede haberse procesado parcialmente. '
            'Conserva las claves de idempotencia al reintentar.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RegistrarUbicacionLoteDataModel>>(
        message: 'Ocurrió un error al sincronizar las ubicaciones.',
        error: error.toString(),
      );
    }
  }
}
