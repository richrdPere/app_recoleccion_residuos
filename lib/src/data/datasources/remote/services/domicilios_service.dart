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

class DomiciliosService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/ciudadanos';

  // Para domicilio
  String get API_CREATE_CIUDADANO_DOMICILIO => '$API_BASE/domicilios';
  String get API_GET_MIS_DOMICILIOS => '$API_BASE/domicilios';
  String get API_UPDATE_CIUDADANO_DOMICILIO => '$API_BASE/domicilios';
  String get API_SET_PRINCIPAL_CIUDADANO_DOMICILIO => '$API_BASE/domicilios';
  String get API_GET_DOMICILIO_CRONOGRAMA => '$API_BASE/domicilios';
  String get API_DELETE_CIUDADANO_DOMICILIO => '$API_BASE/domicilios';
  String get API_RESOLVER_COBERTURA =>
      '$API_BASE/domicilios/resolver-cobertura';

  // *********************************************************
  // 1. REGISTRAR DOMICILIO CIUDADANO
  // *********************************************************
  Future<Resource<ApiResponse<CreateCiudadanoDomicilioDataModel>>>
  createCiudadanoDomicilio({
    required String token,
    required CreateCiudadanoDomicilioRequest request,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<CreateCiudadanoDomicilioDataModel>>(
        message: 'Debes iniciar sesión para registrar tu domicilio.',
        statusCode: 401,
      );
    }

    // VALIDAR COORDENADAS
    if (!request.latitud.isFinite ||
        !request.longitud.isFinite ||
        request.latitud < -90 ||
        request.latitud > 90 ||
        request.longitud < -180 ||
        request.longitud > 180) {
      return ErrorData<ApiResponse<CreateCiudadanoDomicilioDataModel>>(
        message: 'Selecciona una ubicación válida para el domicilio.',
        statusCode: 400,
      );
    }

    final precision = request.precisionUbicacion;

    if (precision != null && (!precision.isFinite || precision < 0)) {
      return ErrorData<ApiResponse<CreateCiudadanoDomicilioDataModel>>(
        message: 'La precisión de ubicación debe ser un valor no negativo.',
        statusCode: 400,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_CREATE_CIUDADANO_DOMICILIO);

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
            ApiResponse<CreateCiudadanoDomicilioDataModel>.fromJson(
              body,
              (rawData) => CreateCiudadanoDomicilioDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<CreateCiudadanoDomicilioDataModel>>(
            message:
                'El servidor no devolvió el domicilio registrado. '
                'Consulta tus domicilios antes de repetir la operación.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<CreateCiudadanoDomicilioDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<CreateCiudadanoDomicilioDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<CreateCiudadanoDomicilioDataModel>>(
        message:
            'No se pudo confirmar el registro del domicilio. '
            'Consulta tus domicilios antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER MIS DOMICILIOS
  // *********************************************************
  Future<Resource<ApiResponse<List<GetMisDomiciliosDataModel>>>>
  getMisDomicilios({
    required String token,
    bool incluirInactivos = false,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<List<GetMisDomiciliosDataModel>>>(
        message: 'Debes iniciar sesión para consultar tus domicilios.',
        statusCode: 401,
      );
    }

    try {
      // 1. CONSTRUIR URL Y QUERY PARAMS
      final baseUri = Uri.parse(API_GET_MIS_DOMICILIOS);

      final uri = baseUri.replace(
        queryParameters: {
          ...baseUri.queryParameters,
          'incluir_inactivos': incluirInactivos.toString(),
        },
      );

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        // [] es válido. null o un objeto no son una lista válida.
        if (body['data'] is! List) {
          return ErrorData<ApiResponse<List<GetMisDomiciliosDataModel>>>(
            message: 'El servidor no devolvió una lista válida de domicilios.',
            statusCode: response.statusCode,
          );
        }

        final apiResponse =
            ApiResponse<List<GetMisDomiciliosDataModel>>.fromJson(
              body,
              (rawData) => (rawData as List)
                  .map(
                    (item) => GetMisDomiciliosDataModel.fromJson(
                      Map<String, dynamic>.from(item as Map),
                    ),
                  )
                  .toList(growable: false),
            );

        return Success<ApiResponse<List<GetMisDomiciliosDataModel>>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<List<GetMisDomiciliosDataModel>>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<List<GetMisDomiciliosDataModel>>>(
        message:
            'No se pudieron consultar tus domicilios. '
            'Inténtalo nuevamente.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. ACTUALIZAR DOMICILIO CIUDADANO
  // *********************************************************
  Future<Resource<ApiResponse<UpdateCiudadanoDomicilioDataModel>>>
  updateCiudadanoDomicilio({
    required String token,
    required int idDomicilio,
    required UpdateCiudadanoDomicilioRequest request,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message: 'Debes iniciar sesión para actualizar tu domicilio.',
        statusCode: 401,
      );
    }

    if (idDomicilio <= 0) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message: 'El identificador del domicilio no es válido.',
        statusCode: 400,
      );
    }

    // VALIDAR COORDENADAS
    if (!request.latitud.isFinite ||
        !request.longitud.isFinite ||
        request.latitud < -90 ||
        request.latitud > 90 ||
        request.longitud < -180 ||
        request.longitud > 180) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message: 'Selecciona una ubicación válida para el domicilio.',
        statusCode: 400,
      );
    }

    final precision = request.precisionUbicacion;

    if (precision != null && (!precision.isFinite || precision < 0)) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message: 'La precisión de ubicación debe ser un valor no negativo.',
        statusCode: 400,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final baseUri = Uri.parse(API_UPDATE_CIUDADANO_DOMICILIO);

      final uri = baseUri.replace(
        path:
            '${baseUri.path.replaceFirst(RegExp(r'/+$'), '')}'
            '/${Uri.encodeComponent(idDomicilio.toString())}',
      );

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
            ApiResponse<UpdateCiudadanoDomicilioDataModel>.fromJson(
              body,
              (rawData) => UpdateCiudadanoDomicilioDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
            message:
                'El servidor no devolvió el domicilio actualizado. '
                'Consulta tus domicilios para verificar los cambios.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<UpdateCiudadanoDomicilioDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message:
            'No se pudo confirmar la actualización del domicilio. '
            'Consulta tus domicilios antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. ESTABLECER DOMICILIO PRINCIPAL
  // *********************************************************
  Future<Resource<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>>
  setPrincipalCiudadanoDomicilio({
    required String token,
    required int idDomicilio,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>(
        message: 'Debes iniciar sesión para establecer tu domicilio principal.',
        statusCode: 401,
      );
    }

    if (idDomicilio <= 0) {
      return ErrorData<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>(
        message: 'El identificador del domicilio no es válido.',
        statusCode: 400,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final baseUri = Uri.parse(API_SET_PRINCIPAL_CIUDADANO_DOMICILIO);

      final uri = baseUri.replace(
        path:
            '${baseUri.path.replaceFirst(RegExp(r'/+$'), '')}'
            '/$idDomicilio/principal',
      );

      // 2. PETICIÓN HTTP SIN BODY
      final response = await http
          .patch(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse =
            ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>.fromJson(
              body,
              (rawData) => SetPrincipalCiudadanoDomicilioDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        final domicilio = apiResponse.data;

        if (domicilio == null ||
            domicilio.idDomicilio != idDomicilio ||
            !domicilio.esPrincipal) {
          return ErrorData<
            ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>
          >(
            message:
                'El servidor no confirmó el domicilio principal. '
                'Consulta tus domicilios para verificar el cambio.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<SetPrincipalCiudadanoDomicilioDataModel>>(
        message:
            'No se pudo confirmar el cambio de domicilio principal. '
            'Consulta tus domicilios antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. OBTENER CRONOGRAMA DEL DOMICILIO
  // *********************************************************
  Future<Resource<ApiResponse<GetDomicilioCronogramaDataModel>>>
  getDomicilioCronograma({
    required String token,
    required int idDomicilio,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
        message: 'Debes iniciar sesión para consultar el cronograma.',
        statusCode: 401,
      );
    }

    if (idDomicilio <= 0) {
      return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
        message: 'El identificador del domicilio no es válido.',
        statusCode: 400,
      );
    }

    // VALIDAR FECHAS SIN CONVERTIRLAS A LA ZONA HORARIA DEL TELÉFONO.
    bool fechaValida(String value) {
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
        return false;
      }

      final date = DateTime.tryParse('${value}T00:00:00Z');

      if (date == null) return false;

      // DateTime puede normalizar fechas como 2026-02-30.
      // Comparar los componentes permite rechazarlas.
      final year = date.year.toString().padLeft(4, '0');
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');

      return '$year-$month-$day' == value;
    }

    if ((fechaDesde != null && !fechaValida(fechaDesde)) ||
        (fechaHasta != null && !fechaValida(fechaHasta))) {
      return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
        message: 'Las fechas deben ser válidas y tener formato YYYY-MM-DD.',
        statusCode: 400,
      );
    }

    if (fechaDesde != null && fechaHasta != null) {
      final desde = DateTime.parse('${fechaDesde}T00:00:00Z');
      final hasta = DateTime.parse('${fechaHasta}T00:00:00Z');

      final diferencia = hasta.difference(desde).inDays;

      // Mismo límite inclusivo que el backend: entre 1 y 93 días.
      if (diferencia < 0 || diferencia > 92) {
        return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
          message: 'El periodo debe contener entre 1 y 93 días.',
          statusCode: 400,
        );
      }
    }

    try {
      // 1. CONSTRUIR URL Y QUERY PARAMS
      final baseUri = Uri.parse(API_GET_DOMICILIO_CRONOGRAMA);

      final queryParameters = <String, String>{
        ...baseUri.queryParameters,
        if (fechaDesde != null) 'fecha_desde': fechaDesde,
        if (fechaHasta != null) 'fecha_hasta': fechaHasta,
      };

      final uri = baseUri.replace(
        path:
            '${baseUri.path.replaceFirst(RegExp(r'/+$'), '')}'
            '/$idDomicilio/cronograma',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        if (body['data'] is! Map) {
          return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
            message: 'El servidor no devolvió un cronograma válido.',
            statusCode: response.statusCode,
          );
        }

        final apiResponse =
            ApiResponse<GetDomicilioCronogramaDataModel>.fromJson(
              body,
              (rawData) => GetDomicilioCronogramaDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
            message: 'El servidor no devolvió el cronograma del domicilio.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<GetDomicilioCronogramaDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<GetDomicilioCronogramaDataModel>
      >(body, response.statusCode);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
        message:
            'La consulta del cronograma tardó demasiado. '
            'Intenta nuevamente.',
        error: error.toString(),
      );
    } on FormatException catch (error) {
      return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
        message: 'El servidor devolvió un cronograma con formato inválido.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>(
        message:
            'No se pudo consultar el cronograma de recolección. '
            'Intenta nuevamente.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. OBTENER SERVICIO ACTIVO DEL DOMICILIO
  // *********************************************************
  Future<Resource<ApiResponse<GetDomicilioServicioActivoDataModel>>>
  getDomicilioServicioActivo({
    required String token,
    required int idDomicilio,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<GetDomicilioServicioActivoDataModel>>(
        message: 'Debes iniciar sesión para consultar el servicio.',
        statusCode: 401,
      );
    }

    if (idDomicilio <= 0) {
      return ErrorData<ApiResponse<GetDomicilioServicioActivoDataModel>>(
        message: 'El identificador del domicilio no es válido.',
        statusCode: 400,
      );
    }

    try {
      // 1. CONSTRUIR URL
      // La misma base /ciudadanos/domicilios del cronograma.
      final baseUri = Uri.parse(API_GET_DOMICILIO_CRONOGRAMA);

      final uri = baseUri.replace(
        path:
            '${baseUri.path.replaceFirst(RegExp(r'/+$'), '')}'
            '/$idDomicilio/servicio-activo',
      );

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse =
            ApiResponse<GetDomicilioServicioActivoDataModel>.fromJson(
              body,
              (rawData) => GetDomicilioServicioActivoDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        final data = apiResponse.data;

        if (data == null) {
          return ErrorData<ApiResponse<GetDomicilioServicioActivoDataModel>>(
            message: 'El servidor no devolvió los datos del servicio.',
            statusCode: response.statusCode,
          );
        }

        if (data.domicilio.idDomicilio != idDomicilio) {
          return ErrorData<ApiResponse<GetDomicilioServicioActivoDataModel>>(
            message:
                'Los datos recibidos no corresponden '
                'al domicilio solicitado.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<GetDomicilioServicioActivoDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<GetDomicilioServicioActivoDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<GetDomicilioServicioActivoDataModel>>(
        message:
            'No se pudo consultar el servicio de recolección. '
            'Inténtalo nuevamente.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 7. ELIMINAR DOMICILIO CIUDADANO
  // *********************************************************
  Future<Resource<ApiResponse<DeleteCiudadanoDomicilioDataModel>>>
  deleteCiudadanoDomicilio({
    required String token,
    required int idDomicilio,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<DeleteCiudadanoDomicilioDataModel>>(
        message: 'Debes iniciar sesión para eliminar tu domicilio.',
        statusCode: 401,
      );
    }

    if (idDomicilio <= 0) {
      return ErrorData<ApiResponse<DeleteCiudadanoDomicilioDataModel>>(
        message: 'El identificador del domicilio no es válido.',
        statusCode: 400,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final baseUri = Uri.parse(API_DELETE_CIUDADANO_DOMICILIO);

      final uri = baseUri.replace(
        path:
            '${baseUri.path.replaceFirst(RegExp(r'/+$'), '')}'
            '/$idDomicilio',
      );

      // 2. PETICIÓN HTTP SIN BODY
      final response = await http
          .delete(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse =
            ApiResponse<DeleteCiudadanoDomicilioDataModel>.fromJson(
              body,
              (rawData) => DeleteCiudadanoDomicilioDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        final resultado = apiResponse.data;

        if (resultado == null ||
            resultado.idDomicilio != idDomicilio ||
            !resultado.eliminado) {
          return ErrorData<ApiResponse<DeleteCiudadanoDomicilioDataModel>>(
            message:
                'El servidor no confirmó la eliminación del domicilio. '
                'Consulta tus domicilios para verificar el resultado.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<DeleteCiudadanoDomicilioDataModel>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<DeleteCiudadanoDomicilioDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<DeleteCiudadanoDomicilioDataModel>>(
        message:
            'No se pudo confirmar la eliminación del domicilio. '
            'Consulta tus domicilios antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 8. RESOLVER COBERTURA DEL DOMICILIO
  // *********************************************************
  Future<Resource<ApiResponse<ResolverCoberturaDataModel>>> resolverCobertura({
    required String token,
    required ResolverCoberturaRequest request,
  }) async {
    // VALIDAR SESIÓN
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<ResolverCoberturaDataModel>>(
        message: 'Debes iniciar sesión para consultar la cobertura.',
        statusCode: 401,
      );
    }

    // VALIDAR COORDENADAS
    if (!request.latitud.isFinite ||
        !request.longitud.isFinite ||
        request.latitud < -90 ||
        request.latitud > 90 ||
        request.longitud < -180 ||
        request.longitud > 180) {
      return ErrorData<ApiResponse<ResolverCoberturaDataModel>>(
        message: 'Selecciona una ubicación válida para el domicilio.',
        statusCode: 400,
      );
    }

    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_RESOLVER_COBERTURA);

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
        if (body['data'] is! Map) {
          return ErrorData<ApiResponse<ResolverCoberturaDataModel>>(
            message: 'El servidor no devolvió datos válidos de cobertura.',
            statusCode: response.statusCode,
          );
        }

        final apiResponse = ApiResponse<ResolverCoberturaDataModel>.fromJson(
          body,
          (rawData) => ResolverCoberturaDataModel.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<ResolverCoberturaDataModel>>(
            message: 'El servidor no devolvió el resultado de cobertura.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<ResolverCoberturaDataModel>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<ResolverCoberturaDataModel>
      >(body, response.statusCode);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<ResolverCoberturaDataModel>>(
        message:
            'La consulta de cobertura tardó demasiado. '
            'Intenta nuevamente.',
        error: error.toString(),
      );
    } on FormatException catch (error) {
      return ErrorData<ApiResponse<ResolverCoberturaDataModel>>(
        message: 'El servidor devolvió una respuesta de cobertura inválida.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<ResolverCoberturaDataModel>>(
        message:
            'No se pudo consultar la cobertura. '
            'Verifica tu conexión e intenta nuevamente.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 9. CAMBIAR ESTADO DEL DOMICILIO
  // *********************************************************
  Future<Resource<ApiResponse<UpdateCiudadanoDomicilioDataModel>>>
  changeEstadoCiudadanoDomicilio({
    required String token,
    required int idDomicilio,
    required bool activo,
  }) async {
    if (token.trim().isEmpty) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message: 'Debes iniciar sesión para cambiar el estado del domicilio.',
        statusCode: 401,
      );
    }

    if (idDomicilio <= 0) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message: 'El identificador del domicilio no es válido.',
        statusCode: 400,
      );
    }

    try {
      final baseUri = Uri.parse(API_UPDATE_CIUDADANO_DOMICILIO);

      final uri = baseUri.replace(
        path:
            '${baseUri.path.replaceFirst(RegExp(r'/+$'), '')}'
            '/$idDomicilio',
      );

      final response = await http
          .put(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode({
              'estado_domicilio': activo ? 'ACTIVO' : 'INACTIVO',
            }),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse =
            ApiResponse<UpdateCiudadanoDomicilioDataModel>.fromJson(
              body,
              (rawData) => UpdateCiudadanoDomicilioDataModel.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        if (apiResponse.data == null) {
          return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
            message:
                'El servidor no devolvió el domicilio actualizado. '
                'Consulta el listado para verificar su estado.',
            statusCode: response.statusCode,
          );
        }

        return Success<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
          apiResponse,
        );
      }

      return HttpServiceHelper.buildError<
        ApiResponse<UpdateCiudadanoDomicilioDataModel>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<UpdateCiudadanoDomicilioDataModel>>(
        message:
            'No se pudo confirmar el cambio de estado. '
            'Consulta el listado antes de repetir la operación.',
        error: error.toString(),
      );
    }
  }
}
