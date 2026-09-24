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

class ProgramacionesService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/programaciones';

  String get API_GET_MIS_ASIGNACIONES => '$API_BASE/mis-asignaciones';
  String get API_RESPONDER_ASIGNACION => '$API_BASE/asignaciones';
  String get API_GET_PROGRAMACION_BY_ID => '$API_BASE/view';

  // *********************************************************
  // 1. OBTENER MIS ASIGNACIONES
  // *********************************************************
  Future<Resource<ApiResponse<MisAsignacionesDataModel>>> getMisAsignaciones({
    required MisAsignacionesFilters filters,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(
        API_GET_MIS_ASIGNACIONES,
      ).replace(queryParameters: filters.toQueryParameters());

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse = ApiResponse<MisAsignacionesDataModel>.fromJson(
          body,
          (rawData) => MisAsignacionesDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<MisAsignacionesDataModel>>(apiResponse);
      }

      // 5. MANEJAR ERROR DEL BACKEND
      return HttpServiceHelper.buildError<
        ApiResponse<MisAsignacionesDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<MisAsignacionesDataModel>>(
        message: 'Ocurrió un error al obtener tus asignaciones.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. RESPONDER ASIGNACIÓN
  // *********************************************************
  Future<Resource<ApiResponse<ResponderAsignacionDataModel>>>
  responderAsignacion({
    required int idProgramacionPersonal,
    required ResponderAsignacionRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(
        '$API_RESPONDER_ASIGNACION/$idProgramacionPersonal/respuesta',
      );

      // 2. PETICIÓN HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse = ApiResponse<ResponderAsignacionDataModel>.fromJson(
          body,
          (rawData) => ResponderAsignacionDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<ResponderAsignacionDataModel>>(apiResponse);
      }

      // 5. MANEJAR ERROR DEL BACKEND
      return HttpServiceHelper.buildError<
        ApiResponse<ResponderAsignacionDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<ResponderAsignacionDataModel>>(
        message: 'Ocurrió un error al responder la asignación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER DETALLE DE PROGRAMACIÓN
  // *********************************************************
  Future<Resource<ApiResponse<ProgramacionDetalleDataModel>>>
  getProgramacionDetalle({
    required int idProgramacion,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_GET_PROGRAMACION_BY_ID/$idProgramacion');

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse = ApiResponse<ProgramacionDetalleDataModel>.fromJson(
          body,
          (rawData) => ProgramacionDetalleDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<ProgramacionDetalleDataModel>>(apiResponse);
      }

      // 5. MANEJAR ERROR DEL BACKEND
      return HttpServiceHelper.buildError<
        ApiResponse<ProgramacionDetalleDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<ProgramacionDetalleDataModel>>(
        message: 'Ocurrió un error al obtener la programación.',
        error: error.toString(),
      );
    }
  }
}
