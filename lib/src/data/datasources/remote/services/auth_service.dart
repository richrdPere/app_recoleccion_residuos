// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Environment
import 'package:app_recoleccion_residuos/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:app_recoleccion_residuos/src/data/datasources/remote/services/helpers/http_service_helper.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Models
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class AuthService with ChangeNotifier {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/auth';

  String get API_LOGIN => '$API_BASE/login';
  String get API_LOGOUT => '$API_BASE/logout';
  String get API_PROFILE_ME => '$API_BASE/me';
  String get API_REFRESH => '$API_BASE/refresh';
  String get API_REGISTER => '$API_BASE/register';

  // *********************************************************
  // 1. LOGIN - INICIAR SESIÓN
  // *********************************************************
  Future<Resource<ApiResponse<LoginDataModel>>> login({
    required LoginRequest request,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_LOGIN);

      // 2. PETICIÓN HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<LoginDataModel>.fromJson(
          body,
          (rawData) => LoginDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<LoginDataModel>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<LoginDataModel>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<LoginDataModel>>(
        message: 'Ocurrió un error al iniciar sesión.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. LOGOUT - CERRAR SESIÓN
  // *********************************************************
  Future<Resource<ApiResponse<LogoutDataModel>>> logout({
    required String token,
    required LogoutRequest request,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_LOGOUT);

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
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<LogoutDataModel>.fromJson(
          body,
          (rawData) => LogoutDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<LogoutDataModel>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<LogoutDataModel>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<LogoutDataModel>>(
        message: 'Ocurrió un error al cerrar la sesión.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER PERFIL DEL USUARIO AUTENTICADO
  // *********************************************************
  Future<Resource<ApiResponse<UsuarioDataModel>>> getProfileMe({
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_PROFILE_ME);

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<UsuarioDataModel>.fromJson(
          body,
          (rawData) => UsuarioDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<UsuarioDataModel>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<UsuarioDataModel>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<UsuarioDataModel>>(
        message: 'Ocurrió un error al cerrar la sesión.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. RENOVAR SESIÓN
  // *********************************************************
  Future<Resource<ApiResponse<RefreshTokenDataModel>>> refreshSession({
    required RefreshTokenRequest request,
  }) async {
    if (request.refreshToken.trim().isEmpty) {
      return ErrorData<ApiResponse<RefreshTokenDataModel>>(
        message: 'No se encontró el token de renovación.',
      );
    }

    try {
      final uri = Uri.parse(API_REFRESH);

      final response = await http
          .post(
            uri,
            // No utiliza el access token vencido.
            headers: HttpServiceHelper.getHeaders(
              extraHeaders: {'x-client-origin': 'APP'},
            ),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // Requiere éxito HTTP y confirmación del backend.
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<ApiResponse<RefreshTokenDataModel>>(
          body,
          response.statusCode,
        );
      }

      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<RefreshTokenDataModel>>(
          message:
              'La respuesta del servidor no contiene '
              'datos válidos de renovación.',
          statusCode: response.statusCode,
        );
      }

      final apiResponse = ApiResponse<RefreshTokenDataModel>.fromJson(
        body,
        (rawData) => RefreshTokenDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<RefreshTokenDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<RefreshTokenDataModel>>(
        message:
            'El servidor tardó demasiado en responder '
            'al renovar la sesión.',
        error: error.toString(),
      );
    } on FormatException catch (error) {
      return ErrorData<ApiResponse<RefreshTokenDataModel>>(
        message: 'La respuesta de renovación tiene un formato inválido.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<RefreshTokenDataModel>>(
        message:
            'No se pudo renovar la sesión. '
            'Verifica tu conexión e inténtalo nuevamente.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. REGISTER - REGISTRAR CIUDADANO
  // *********************************************************
  Future<Resource<ApiResponse<RegisterCiudadanoDataModel>>> registerCiudadano({
    required RegisterCiudadanoRequest request,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_REGISTER);

      // 2. PETICIÓN HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse = ApiResponse<RegisterCiudadanoDataModel>.fromJson(
          body,
          (rawData) => RegisterCiudadanoDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<RegisterCiudadanoDataModel>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<RegisterCiudadanoDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<RegisterCiudadanoDataModel>>(
        message:
            'No se pudo completar el registro. Si la solicitud llegó '
            'al servidor, la cuenta podría haberse creado; intenta '
            'iniciar sesión antes de repetir el registro.',
        error: error.toString(),
      );
    }
  }
}
