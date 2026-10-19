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

class CiudadanosService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/ciudadanos';

  // Para ciudadano
  String get API_CREATE_PERFIL_CIUDADANO => '$API_BASE/perfil';
  String get API_GET_MI_PERFIL_CIUDADANO => '$API_BASE/me';
  String get API_UPDATE_MI_PERFIL_CIUDADANO => '$API_BASE/me';

  // *********************************************************
  // 1. CREAR PERFIL CIUDADANO
  // *********************************************************
  Future<Resource<ApiResponse<CreateCiudadanoPerfilDataModel>>>
  createCiudadanoPerfil({
    required String token,
    required CreateCiudadanoPerfilRequest request,
  }) async {
    // VALIDAR TOKEN ANTES DE REALIZAR LA PETICIÓN
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<CreateCiudadanoPerfilDataModel>>(
        message: 'Debes iniciar sesión para crear tu perfil ciudadano.',
        statusCode: 401,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_CREATE_PERFIL_CIUDADANO);

      // 2. PETICIÓN HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse =
            ApiResponse<CreateCiudadanoPerfilDataModel>.fromJson(
              body,
              (rawData) => CreateCiudadanoPerfilDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        // La creación debe devolver el perfil.
        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<CreateCiudadanoPerfilDataModel>>(
            message:
                'El servidor no devolvió el perfil creado. '
                'Consulta tu perfil antes de repetir la operación.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<CreateCiudadanoPerfilDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<CreateCiudadanoPerfilDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<CreateCiudadanoPerfilDataModel>>(
        message:
            'No se pudo confirmar la creación del perfil ciudadano. '
            'Consulta tu perfil antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER MI PERFIL CIUDADANO
  // *********************************************************
  Future<Resource<ApiResponse<GetCiudadanoPerfilDataModel>>>
  getMiPerfilCiudadano({required String token}) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<GetCiudadanoPerfilDataModel>>(
        message: 'Debes iniciar sesión para consultar tu perfil ciudadano.',
        statusCode: 401,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_GET_MI_PERFIL_CIUDADANO);

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse = ApiResponse<GetCiudadanoPerfilDataModel>.fromJson(
          body,
          (rawData) => GetCiudadanoPerfilDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<GetCiudadanoPerfilDataModel>>(
            message: 'El servidor no devolvió los datos del perfil ciudadano.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<GetCiudadanoPerfilDataModel>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      // Conserva el statusCode, incluido el 404 si falta el perfil.
      return HttpServiceHelper.buildError<
        ApiResponse<GetCiudadanoPerfilDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<GetCiudadanoPerfilDataModel>>(
        message:
            'No se pudo consultar tu perfil ciudadano. '
            'Verifica tu conexión e inténtalo nuevamente.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. ACTUALIZAR MI PERFIL CIUDADANO
  // *********************************************************
  Future<Resource<ApiResponse<UpdateCiudadanoPerfilDataModel>>>
  updateMiPerfilCiudadano({
    required String token,
    required UpdateCiudadanoPerfilRequest request,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<UpdateCiudadanoPerfilDataModel>>(
        message: 'Debes iniciar sesión para actualizar tu perfil ciudadano.',
        statusCode: 401,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_UPDATE_MI_PERFIL_CIUDADANO);

      // 2. PETICIÓN HTTP
      final response = await http
          .put(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse =
            ApiResponse<UpdateCiudadanoPerfilDataModel>.fromJson(
              body,
              (rawData) => UpdateCiudadanoPerfilDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<UpdateCiudadanoPerfilDataModel>>(
            message:
                'El servidor no devolvió el perfil actualizado. '
                'Consulta tu perfil para verificar los cambios.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<UpdateCiudadanoPerfilDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<UpdateCiudadanoPerfilDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<UpdateCiudadanoPerfilDataModel>>(
        message:
            'No se pudo confirmar la actualización del perfil ciudadano. '
            'Consulta tu perfil antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }
}
