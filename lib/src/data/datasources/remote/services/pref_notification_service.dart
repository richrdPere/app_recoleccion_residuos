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

class PrefNotificationService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/ciudadanos';

  // Para preferencia notificaciones
  String get API_GET_CIUDADANO_PREFERENCIAS =>
      '$API_BASE/preferencias-notificacion';
  String get API_UPDATE_CIUDADANO_PREFERENCIAS =>
      '$API_BASE/preferencias-notificacion';

  // *********************************************************
  // 1. OBTENER PREFERENCIAS DE NOTIFICACIÓN
  // *********************************************************
  Future<Resource<ApiResponse<GetCiudadanoPreferenciasDataModel>>>
  getCiudadanoPreferencias({required String token}) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<GetCiudadanoPreferenciasDataModel>>(
        message: 'Debes iniciar sesión para consultar tus preferencias.',
        statusCode: 401,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_GET_CIUDADANO_PREFERENCIAS);

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse =
            ApiResponse<GetCiudadanoPreferenciasDataModel>.fromJson(
              body,
              (rawData) => GetCiudadanoPreferenciasDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<GetCiudadanoPreferenciasDataModel>>(
            message:
                'El servidor no devolvió las preferencias de notificación.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<GetCiudadanoPreferenciasDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<GetCiudadanoPreferenciasDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<GetCiudadanoPreferenciasDataModel>>(
        message:
            'No se pudieron consultar tus preferencias de notificación. '
            'Inténtalo nuevamente.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. ACTUALIZAR PREFERENCIAS DE NOTIFICACIÓN
  // *********************************************************
  Future<Resource<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>>
  updateCiudadanoPreferencias({
    required String token,
    required UpdateCiudadanoPreferenciasRequest request,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>(
        message: 'Debes iniciar sesión para actualizar tus preferencias.',
        statusCode: 401,
      );
    }

    // VALIDAR ANTICIPACIÓN
    if (request.minutosAnticipacion < 0) {
      return ErrorData<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>(
        message: 'Los minutos de anticipación no pueden ser negativos.',
        statusCode: 400,
      );
    }

    if (request.frecuenciaRecordatorio.trim().isEmpty) {
      return ErrorData<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>(
        message: 'Selecciona la frecuencia del recordatorio.',
        statusCode: 400,
      );
    }

    // VALIDAR HORARIO DE SILENCIO
    final inicio = request.horaSilencioInicio?.trim();
    final fin = request.horaSilencioFin?.trim();

    final formatoHora = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$');

    if ((inicio == null) != (fin == null) ||
        (inicio != null && !formatoHora.hasMatch(inicio)) ||
        (fin != null && !formatoHora.hasMatch(fin))) {
      return ErrorData<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>(
        message:
            'Indica ambas horas de silencio en formato HH:mm:ss '
            'o deja ambas sin configurar.',
        statusCode: 400,
      );
    }

    // Se permiten intervalos que cruzan medianoche:
    // por ejemplo, 22:00:00 a 06:00:00.

    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_UPDATE_CIUDADANO_PREFERENCIAS);

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
            ApiResponse<UpdateCiudadanoPreferenciasDataModel>.fromJson(
              body,
              (rawData) => UpdateCiudadanoPreferenciasDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>(
            message:
                'El servidor no devolvió las preferencias actualizadas. '
                'Consulta tus preferencias para verificar los cambios.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<UpdateCiudadanoPreferenciasDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<UpdateCiudadanoPreferenciasDataModel>>(
        message:
            'No se pudo confirmar la actualización de tus preferencias. '
            'Consúltalas antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }
}
