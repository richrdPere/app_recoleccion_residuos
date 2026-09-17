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

// Modelos

class ProgramacionesService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/programaciones';

  String get API_GET_MIS_ASIGNACIONES => '$API_BASE/mis-asignaciones';
  String get API_PATCH_RESPUESTA =>
      '$API_BASE/asignaciones/'; //:idProgramacionPersonal/respuesta
  String get API_GET_PROGRAMACION_BY_ID => '$API_BASE/view/';
}
