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
}
