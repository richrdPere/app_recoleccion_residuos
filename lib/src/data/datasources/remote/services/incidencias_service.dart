// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// Environment
import 'package:app_recoleccion_residuos/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:app_recoleccion_residuos/src/data/datasources/remote/services/helpers/http_service_helper.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:http_parser/http_parser.dart';

class IncidenciasService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/incidencias';

  String get API_GET_INCIDENCIAS_PAGINADAS => '$API_BASE/paginado';
  String get API_GET_INCIDENCIA_BY_ID => '$API_BASE/view';
  String get API_CREATE_INCIDENCIA => '$API_BASE/create';
  String get API_UPDATE_INCIDENCIA => '$API_BASE/update';
  String get API_PATCH_ESTADO_INCIDENCIA => API_BASE;

  // Para archivos
  String get API_INCIDENCIA_ARCHIVOS => API_BASE;

  // *********************************************************
  // 1. CREAR INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<CreateIncidenciaDataModel>>> createIncidencia({
    required CreateIncidenciaRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_CREATE_INCIDENCIA);

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
          ApiResponse<CreateIncidenciaDataModel>
        >(body, response.statusCode);
      }

      // 5. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<CreateIncidenciaDataModel>>(
          message:
              'La respuesta del servidor no contiene una incidencia válida.',
          statusCode: response.statusCode,
        );
      }

      // 6. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<CreateIncidenciaDataModel>.fromJson(
        body,
        (rawData) => CreateIncidenciaDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<CreateIncidenciaDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<CreateIncidenciaDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Verifica si la incidencia fue registrada antes de volver a enviarla.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<CreateIncidenciaDataModel>>(
        message: 'Ocurrió un error al registrar la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER INCIDENCIAS PAGINADAS
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciasPaginadasDataModel>>>
  getIncidenciasPaginadas({
    required IncidenciasPaginadasFilters filters,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(
        API_GET_INCIDENCIAS_PAGINADAS,
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
        final apiResponse = ApiResponse<IncidenciasPaginadasDataModel>.fromJson(
          body,
          (rawData) {
            if (rawData is! Map) {
              throw const FormatException(
                'Los datos de incidencias no tienen un formato válido.',
              );
            }

            return IncidenciasPaginadasDataModel.fromJson(
              Map<String, dynamic>.from(rawData),
            );
          },
        );

        return Success<ApiResponse<IncidenciasPaginadasDataModel>>(apiResponse);
      }

      // 5. ERROR DEL BACKEND
      return HttpServiceHelper.buildError<
        ApiResponse<IncidenciasPaginadasDataModel>
      >(body, response.statusCode);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<IncidenciasPaginadasDataModel>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } on http.ClientException catch (error) {
      return ErrorData<ApiResponse<IncidenciasPaginadasDataModel>>(
        message: 'No se pudo establecer la conexión con el servidor.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciasPaginadasDataModel>>(
        message: 'Ocurrió un error al obtener las incidencias.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER INCIDENCIA POR ID
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciaDetalleModel>>> getIncidenciaById({
    required int idIncidencia,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse('$API_GET_INCIDENCIA_BY_ID/$idIncidencia');

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 4. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode) &&
          body['success'] == true) {
        final apiResponse = ApiResponse<IncidenciaDetalleModel>.fromJson(body, (
          rawData,
        ) {
          if (rawData is! Map) {
            throw const FormatException(
              'El detalle de la incidencia no tiene un formato válido.',
            );
          }

          return IncidenciaDetalleModel.fromJson(
            Map<String, dynamic>.from(rawData),
          );
        });

        return Success<ApiResponse<IncidenciaDetalleModel>>(apiResponse);
      }

      // 5. ERROR DEL BACKEND
      return HttpServiceHelper.buildError<ApiResponse<IncidenciaDetalleModel>>(
        body,
        response.statusCode,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<IncidenciaDetalleModel>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } on http.ClientException catch (error) {
      return ErrorData<ApiResponse<IncidenciaDetalleModel>>(
        message: 'No se pudo establecer la conexión con el servidor.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciaDetalleModel>>(
        message: 'Ocurrió un error al obtener el detalle de la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. AGREGAR ARCHIVOS A UNA INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<List<IncidenciaArchivoCreadoModel>>>>
  agregarArchivos({
    required int idIncidencia,
    required AgregarIncidenciaArchivosRequest request,
    required String token,
  }) async {
    try {
      // 1. VALIDAR IDENTIFICADOR
      if (idIncidencia <= 0) {
        return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
          message: 'El identificador de la incidencia no es válido.',
        );
      }

      // Copiamos la lista para mantener estable esta solicitud.
      final archivosPaths = List<String>.of(
        request.archivosPaths,
        growable: false,
      );

      // 2. VALIDAR CANTIDAD
      if (archivosPaths.isEmpty) {
        return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
          message: 'Selecciona al menos un archivo.',
        );
      }

      if (archivosPaths.length > 10) {
        return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
          message: 'Puedes adjuntar como máximo 10 archivos por envío.',
        );
      }

      // 3. VALIDAR DESCRIPCIÓN
      final descripcion = request.descripcion?.trim();

      if (descripcion != null && descripcion.length > 500) {
        return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
          message:
              'La descripción de los archivos admite como máximo 500 caracteres.',
        );
      }

      // 4. VALIDAR ARCHIVOS LOCALES Y MIME
      const allowedMimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
        'pdf': 'application/pdf',
      };

      final mimeTypes = <String>[];

      for (var index = 0; index < archivosPaths.length; index++) {
        final archivoPath = archivosPaths[index];
        final numero = index + 1;

        if (archivoPath.trim().isEmpty) {
          return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
            message: 'La ruta del archivo $numero está vacía.',
          );
        }

        final file = File(archivoPath);

        if (!await file.exists()) {
          return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
            message: 'El archivo $numero ya no existe en el dispositivo.',
          );
        }

        final fileSize = await file.length();

        if (fileSize == 0) {
          return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
            message: 'El archivo $numero está vacío.',
          );
        }

        if (fileSize > 5 * 1024 * 1024) {
          return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
            message: 'El archivo $numero supera el límite de 5 MiB.',
          );
        }

        final extension = HttpServiceHelper.getExtension(archivoPath);

        final mimeType = allowedMimeTypes[extension];

        if (mimeType == null) {
          return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
            message:
                'El archivo $numero no está permitido. '
                'Selecciona archivos JPG, PNG, WebP o PDF.',
          );
        }

        mimeTypes.add(mimeType);
      }

      // 5. CONSTRUIR URL Y MULTIPART
      final uri = Uri.parse('$API_INCIDENCIA_ARCHIVOS/$idIncidencia/archivos');

      final multipartRequest = http.MultipartRequest('POST', uri);

      multipartRequest.headers.addAll(
        HttpServiceHelper.getMultipartHeaders(token: token),
      );

      multipartRequest.fields.addAll(request.toFields());

      // El campo debe llamarse "archivos", en plural.
      for (var index = 0; index < archivosPaths.length; index++) {
        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            'archivos',
            archivosPaths[index],
            contentType: MediaType.parse(mimeTypes[index]),
          ),
        );
      }

      // 6. ENVIAR Y LEER LA RESPUESTA COMPLETA
      final response = await (() async {
        final streamedResponse = await multipartRequest.send();

        return await http.Response.fromStream(streamedResponse);
      })().timeout(const Duration(seconds: 60));

      // 7. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 8. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<List<IncidenciaArchivoCreadoModel>>
        >(body, response.statusCode);
      }

      // 9. VALIDAR DATA
      if (body['data'] is! List) {
        return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
          message:
              'La respuesta del servidor no contiene una lista válida de evidencias.',
          statusCode: response.statusCode,
        );
      }

      // 10. MAPEAR RESPUESTA EXITOSA
      final apiResponse =
          ApiResponse<List<IncidenciaArchivoCreadoModel>>.fromJson(body, (
            rawData,
          ) {
            if (rawData is! List) {
              throw const FormatException(
                'La respuesta de evidencias debe ser una lista.',
              );
            }

            return rawData.map((item) {
              if (item is! Map) {
                throw const FormatException(
                  'La evidencia registrada no tiene un formato válido.',
                );
              }

              return IncidenciaArchivoCreadoModel.fromJson(
                Map<String, dynamic>.from(item),
              );
            }).toList();
          });

      return Success<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
        apiResponse,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
        message:
            'La carga tardó demasiado en responder. '
            'Verifica si las evidencias fueron registradas antes de volver a enviarlas.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<List<IncidenciaArchivoCreadoModel>>>(
        message: 'Ocurrió un error al registrar las evidencias.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. OBTENER ARCHIVOS POR INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<List<IncidenciaArchivoListadoModel>>>>
  getArchivosPorIncidencia({
    required int idIncidencia,
    required String token,
  }) async {
    try {
      // 1. VALIDAR IDENTIFICADOR
      if (idIncidencia <= 0) {
        return ErrorData<ApiResponse<List<IncidenciaArchivoListadoModel>>>(
          message: 'El identificador de la incidencia no es válido.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse('$API_INCIDENCIA_ARCHIVOS/$idIncidencia/archivos');

      // 3. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<List<IncidenciaArchivoListadoModel>>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      // Una lista vacía es una respuesta válida.
      if (body['data'] is! List) {
        return ErrorData<ApiResponse<List<IncidenciaArchivoListadoModel>>>(
          message:
              'La respuesta del servidor no contiene una lista válida de archivos.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA EXITOSA
      final apiResponse =
          ApiResponse<List<IncidenciaArchivoListadoModel>>.fromJson(body, (
            rawData,
          ) {
            if (rawData is! List) {
              throw const FormatException(
                'Los archivos de la incidencia deben ser una lista.',
              );
            }

            return rawData.map((item) {
              if (item is! Map) {
                throw const FormatException(
                  'Uno de los archivos no tiene un formato válido.',
                );
              }

              return IncidenciaArchivoListadoModel.fromJson(
                Map<String, dynamic>.from(item),
              );
            }).toList();
          });

      return Success<ApiResponse<List<IncidenciaArchivoListadoModel>>>(
        apiResponse,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<List<IncidenciaArchivoListadoModel>>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } on http.ClientException catch (error) {
      return ErrorData<ApiResponse<List<IncidenciaArchivoListadoModel>>>(
        message: 'No se pudo establecer la conexión con el servidor.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<List<IncidenciaArchivoListadoModel>>>(
        message: 'Ocurrió un error al obtener los archivos de la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. OBTENER ARCHIVO POR INCIDENCIA E ID DE ARCHIVO
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciaArchivoDetalleModel>>> getArchivoPorId({
    required int idIncidencia,
    required int idArchivo,
    required String token,
  }) async {
    try {
      // 1. VALIDAR IDENTIFICADORES
      if (idIncidencia <= 0) {
        return ErrorData<ApiResponse<IncidenciaArchivoDetalleModel>>(
          message: 'El identificador de la incidencia no es válido.',
        );
      }

      if (idArchivo <= 0) {
        return ErrorData<ApiResponse<IncidenciaArchivoDetalleModel>>(
          message: 'El identificador del archivo no es válido.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse(
        '$API_INCIDENCIA_ARCHIVOS/$idIncidencia/archivos/$idArchivo',
      );

      // 3. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<IncidenciaArchivoDetalleModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<IncidenciaArchivoDetalleModel>>(
          message: 'La respuesta del servidor no contiene un archivo válido.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<IncidenciaArchivoDetalleModel>.fromJson(
        body,
        (rawData) => IncidenciaArchivoDetalleModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<IncidenciaArchivoDetalleModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<IncidenciaArchivoDetalleModel>>(
        message:
            'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: error.toString(),
      );
    } on http.ClientException catch (error) {
      return ErrorData<ApiResponse<IncidenciaArchivoDetalleModel>>(
        message: 'No se pudo establecer la conexión con el servidor.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciaArchivoDetalleModel>>(
        message: 'Ocurrió un error al obtener el archivo de la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 7. ELIMINAR ARCHIVO DE INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<DeleteIncidenciaArchivoDataModel>>>
  deleteArchivo({
    required int idIncidencia,
    required int idArchivo,
    required String token,
  }) async {
    try {
      // 1. VALIDAR IDENTIFICADORES
      if (idIncidencia <= 0) {
        return ErrorData<ApiResponse<DeleteIncidenciaArchivoDataModel>>(
          message: 'El identificador de la incidencia no es válido.',
        );
      }

      if (idArchivo <= 0) {
        return ErrorData<ApiResponse<DeleteIncidenciaArchivoDataModel>>(
          message: 'El identificador del archivo no es válido.',
        );
      }

      // 2. CONSTRUIR URL
      final uri = Uri.parse(
        '$API_INCIDENCIA_ARCHIVOS/$idIncidencia/archivos/$idArchivo',
      );

      // 3. PETICIÓN HTTP
      final response = await http
          .delete(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 4. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 5. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<DeleteIncidenciaArchivoDataModel>
        >(body, response.statusCode);
      }

      // 6. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<DeleteIncidenciaArchivoDataModel>>(
          message:
              'La respuesta del servidor no contiene un resultado válido de eliminación.',
          statusCode: response.statusCode,
        );
      }

      // 7. MAPEAR RESPUESTA EXITOSA
      final apiResponse =
          ApiResponse<DeleteIncidenciaArchivoDataModel>.fromJson(
            body,
            (rawData) => DeleteIncidenciaArchivoDataModel.fromJson(
              Map<String, dynamic>.from(rawData as Map),
            ),
          );

      return Success<ApiResponse<DeleteIncidenciaArchivoDataModel>>(
        apiResponse,
      );
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<DeleteIncidenciaArchivoDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Actualiza el listado para comprobar si el archivo fue eliminado.',
        error: error.toString(),
      );
    } on http.ClientException catch (error) {
      return ErrorData<ApiResponse<DeleteIncidenciaArchivoDataModel>>(
        message:
            'No se pudo completar la comunicación con el servidor. '
            'Actualiza el listado para comprobar el estado del archivo.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<DeleteIncidenciaArchivoDataModel>>(
        message: 'Ocurrió un error al eliminar el archivo de la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 8. ACTUALIZAR INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<UpdateIncidenciaDataModel>>> updateIncidencia({
    required int idIncidencia,
    required UpdateIncidenciaRequest request,
    required String token,
  }) async {
    try {
      // 1. VALIDAR IDENTIFICADOR
      if (idIncidencia <= 0) {
        return ErrorData<ApiResponse<UpdateIncidenciaDataModel>>(
          message: 'El identificador de la incidencia no es válido.',
        );
      }

      // 2. CONSTRUIR BODY
      final payload = request.toJson();

      if (payload.isEmpty) {
        return ErrorData<ApiResponse<UpdateIncidenciaDataModel>>(
          message: 'Debes enviar al menos un campo para actualizar.',
        );
      }

      // 3. CONSTRUIR URL
      final uri = Uri.parse('$API_UPDATE_INCIDENCIA/$idIncidencia');

      // 4. PETICIÓN HTTP
      final response = await http
          .put(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<UpdateIncidenciaDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<UpdateIncidenciaDataModel>>(
          message:
              'La respuesta del servidor no contiene una incidencia válida.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<UpdateIncidenciaDataModel>.fromJson(
        body,
        (rawData) => UpdateIncidenciaDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<UpdateIncidenciaDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<UpdateIncidenciaDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta el detalle para comprobar si los cambios fueron guardados.',
        error: error.toString(),
      );
    } on http.ClientException catch (error) {
      return ErrorData<ApiResponse<UpdateIncidenciaDataModel>>(
        message:
            'No se pudo completar la comunicación con el servidor. '
            'Consulta el detalle para comprobar si los cambios fueron guardados.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<UpdateIncidenciaDataModel>>(
        message: 'Ocurrió un error al actualizar la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 9. CAMBIAR ESTADO DE INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<ChangeIncidenciaEstadoDataModel>>>
  changeIncidenciaEstado({
    required int idIncidencia,
    required ChangeIncidenciaEstadoRequest request,
    required String token,
  }) async {
    try {
      // 1. VALIDAR IDENTIFICADOR
      if (idIncidencia <= 0) {
        return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
          message: 'El identificador de la incidencia no es válido.',
        );
      }

      // 2. VALIDAR ESTADO DE DESTINO
      const estadosPermitidos = {
        'EN_REVISION',
        'EN_ATENCION',
        'RESUELTA',
        'RECHAZADA',
        'CANCELADA',
      };

      if (!estadosPermitidos.contains(request.estadoIncidencia)) {
        return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
          message: 'El estado de destino no es válido.',
        );
      }

      final esCierre = {
        'RESUELTA',
        'RECHAZADA',
        'CANCELADA',
      }.contains(request.estadoIncidencia);

      final detalle = request.detalleResolucion?.trim();

      if (esCierre &&
          (detalle == null || detalle.length < 3 || detalle.length > 15000)) {
        return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
          message:
              'El detalle de cierre debe contener entre 3 y 15000 caracteres.',
        );
      }

      if (!esCierre && request.detalleResolucion != null) {
        return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
          message:
              'El detalle de resolución solo corresponde a un estado de cierre.',
        );
      }

      // 3. CONSTRUIR URL
      final uri = Uri.parse(
        '$API_PATCH_ESTADO_INCIDENCIA/$idIncidencia/estado',
      );

      // 4. PETICIÓN HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 5. DECODIFICAR RESPUESTA
      final body = HttpServiceHelper.decodeResponse(response);

      // 6. VALIDAR ERRORES HTTP Y DEL BODY
      if (!HttpServiceHelper.isSuccess(response.statusCode) ||
          body['success'] != true) {
        return HttpServiceHelper.buildError<
          ApiResponse<ChangeIncidenciaEstadoDataModel>
        >(body, response.statusCode);
      }

      // 7. VALIDAR DATA
      if (body['data'] is! Map) {
        return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
          message:
              'La respuesta del servidor no contiene una incidencia válida.',
          statusCode: response.statusCode,
        );
      }

      // 8. MAPEAR RESPUESTA EXITOSA
      final apiResponse = ApiResponse<ChangeIncidenciaEstadoDataModel>.fromJson(
        body,
        (rawData) => ChangeIncidenciaEstadoDataModel.fromJson(
          Map<String, dynamic>.from(rawData as Map),
        ),
      );

      return Success<ApiResponse<ChangeIncidenciaEstadoDataModel>>(apiResponse);
    } on TimeoutException catch (error) {
      return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
        message:
            'El servidor tardó demasiado en responder. '
            'Consulta el detalle para comprobar si el estado fue actualizado.',
        error: error.toString(),
      );
    } on http.ClientException catch (error) {
      return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
        message:
            'No se pudo completar la comunicación con el servidor. '
            'Consulta el detalle para comprobar el estado actual.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<ApiResponse<ChangeIncidenciaEstadoDataModel>>(
        message: 'Ocurrió un error al actualizar el estado de la incidencia.',
        error: error.toString(),
      );
    }
  }
}
