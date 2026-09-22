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

class DispositivosService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/notificaciones';

  String get API_REGISTRAR_DISPOSITIVO => '${this.API_BASE}/register';
  String get API_GET_MIS_DISPOSITIVOS => '${this.API_BASE}/mis-dispositivos';
  String get API_DESACTIVATED_DISPOSITIVO_BY_TOKEN =>
      '${this.API_BASE}/token/desactivar';
  String get API_DESACTIVATED_DISPOSITIVO_BY_ID => this.API_BASE;

  // *********************************************************
  // 1. REGISTRAR DISPOSITIVO
  // *********************************************************
  Future<Resource<ApiResponse<RegistrarDispositivoDataModel>>>
  registrarDispositivo({
    required RegistrarDispositivoRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_REGISTRAR_DISPOSITIVO);

      // 2. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 3. PETICIÓN HTTP
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<RegistrarDispositivoDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RegistrarDispositivoDataModel>>(
          message: 'La respuesta del servidor no contiene un registro válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<RegistrarDispositivoDataModel>.fromJson(
        body,
        (rawData) => RegistrarDispositivoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RegistrarDispositivoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RegistrarDispositivoDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'No se pudo confirmar el registro del dispositivo.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RegistrarDispositivoDataModel>>(
        message: 'Ocurrió un error al registrar el dispositivo.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER MIS DISPOSITIVOS
  // *********************************************************
  Future<Resource<ApiResponse<List<MiDispositivoDataModel>>>>
  getMisDispositivos({required String token}) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_GET_MIS_DISPOSITIVOS);

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
          ApiResponse<List<MiDispositivoDataModel>>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! List) {
        return ErrorData<ApiResponse<List<MiDispositivoDataModel>>>(
          message: 'La respuesta del servidor no contiene un listado válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<List<MiDispositivoDataModel>>.fromJson(
        body,
        (rawData) => (rawData as List)
            .map(
              (item) => MiDispositivoDataModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );

      return Success<ApiResponse<List<MiDispositivoDataModel>>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<List<MiDispositivoDataModel>>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<List<MiDispositivoDataModel>>>(
        message: 'Ocurrió un error al obtener tus dispositivos.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. DESACTIVAR DISPOSITIVO
  // *********************************************************
  Future<Resource<ApiResponse<DesactivarDispositivoDataModel>>>
  desactivarDispositivo({
    required int idDispositivo,
    required String token,
    DesactivarDispositivoRequest request = const DesactivarDispositivoRequest(),
  }) async {
    try {
      // 1. VALIDAR ID
      if (idDispositivo <= 0) {
        return ErrorData<ApiResponse<DesactivarDispositivoDataModel>>(
          message: 'El identificador del dispositivo no es válido.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse(
        '$API_DESACTIVATED_DISPOSITIVO_BY_ID/$idDispositivo/desactivar',
      );

      // 3. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 4. PETICIÓN HTTP
      final response = await http
          .patch(uri, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(const Duration(seconds: 30));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<DesactivarDispositivoDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<DesactivarDispositivoDataModel>>(
          message: 'La respuesta del servidor no contiene un resultado válido.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA
      final apiResponse = ApiResponse<DesactivarDispositivoDataModel>.fromJson(
        body,
        (rawData) => DesactivarDispositivoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<DesactivarDispositivoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<DesactivarDispositivoDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta tus dispositivos para verificar su estado.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<DesactivarDispositivoDataModel>>(
        message: 'Ocurrió un error al desactivar el dispositivo.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. DESACTIVAR DISPOSITIVO POR TOKEN
  // *********************************************************
  Future<Resource<ApiResponse<DesactivarDispositivoTokenDataModel>>>
  desactivarDispositivoPorToken({
    required DesactivarDispositivoTokenRequest request,
    required String token,
  }) async {
    try {
      // 1. VALIDAR REQUEST
      if (request.tokenPush.trim().isEmpty) {
        return ErrorData<ApiResponse<DesactivarDispositivoTokenDataModel>>(
          message: 'Debe indicar el token push del dispositivo.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse(API_DESACTIVATED_DISPOSITIVO_BY_TOKEN);

      // 3. HEADERS
      final headers = {
        ...HttpServiceHelper.getHeaders(token: token),
        'x-client-origin': 'MOVIL',
      };

      // 4. PETICIÓN HTTP
      final response = await http
          .patch(uri, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(const Duration(seconds: 30));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<DesactivarDispositivoTokenDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<DesactivarDispositivoTokenDataModel>>(
          message: 'La respuesta del servidor no contiene un resultado válido.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA
      final apiResponse =
          ApiResponse<DesactivarDispositivoTokenDataModel>.fromJson(
            body,
            (rawData) => DesactivarDispositivoTokenDataModel.fromJson(
              Map<String, dynamic>.from(rawData as Map),
            ),
          );

      return Success<ApiResponse<DesactivarDispositivoTokenDataModel>>(
        apiResponse,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<DesactivarDispositivoTokenDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta tus dispositivos para verificar su estado.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<DesactivarDispositivoTokenDataModel>>(
        message: 'Ocurrió un error al desactivar el dispositivo por token.',
        error: error.toString(),
      );
    }
  }
}
