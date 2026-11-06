import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:app_recoleccion_residuos/src/config/constants/environment.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_state.dart';
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class OperacionOffline extends ChangeNotifier with WidgetsBindingObserver {
  OperacionOffline._();

  static final instance = OperacionOffline._();

  SessionBloc? _session;
  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<geo.Position>? _gps;

  Future<Database>? _opening;
  Future<void> _local = Future.value();
  Future<void> _sensor = Future.value();

  Timer? _timer;

  bool _syncing = false;

  int? _gpsRoute;
  int _gpsVersion = 0;

  DateTime? _ultimaMuestra;
  String? _identity;

  VoidCallback? onRecorridoSincronizado;

  int pendientes = 0;
  int bloqueadas = 0;
  String? mensaje;

  bool get capturando => _gps != null;
  bool get sincronizando => _syncing;

  int? get _owner => _session?.state.isAuthenticated == true
      ? _session!.state.session!.usuario.idUsuario
      : null;

  bool get _esOperativo {
    final usuario = _session?.state.session?.usuario;

    return usuario != null &&
        (usuario.esConductor ||
            usuario.tieneRol('RECOLECTOR') ||
            usuario.tieneRol('SUPERVISOR'));
  }

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _redSub;

  Timer? _reconexionTimer;

  String? _ultimaFirmaRed;
  String? _sincronizacionSolicitadaPara;

  int _revisionRed = 0;

  static const _acciones = ['pausar', 'reanudar', 'finalizar'];

  // ========================================================
  // BASE LOCAL
  // ========================================================

  Future<Database> get _db => _opening ??= _abrir();

  Future<Database> _abrir() async {
    return openDatabase(
      '${await getDatabasesPath()}/operacion_offline_v1.db',
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE cola(
            seq INTEGER PRIMARY KEY AUTOINCREMENT,
            clave TEXT NOT NULL UNIQUE,
            usuario INTEGER NOT NULL,
            recorrido INTEGER NOT NULL,
            tipo TEXT NOT NULL,
            payload TEXT NOT NULL,
            estado TEXT NOT NULL DEFAULT 'pendiente',
            intentos INTEGER NOT NULL DEFAULT 0,
            proximo INTEGER NOT NULL DEFAULT 0,
            error TEXT,
            respuesta TEXT
          )
        ''');

        await db.execute(
          'CREATE INDEX cola_usuario '
          'ON cola(usuario, estado, seq)',
        );

        await db.execute(
          'CREATE TABLE contexto('
          'usuario INTEGER PRIMARY KEY, documento TEXT)',
        );

        await db.execute('''
          CREATE TABLE cache(
            usuario INTEGER NOT NULL,
            ruta TEXT NOT NULL,
            documento TEXT NOT NULL,
            PRIMARY KEY(usuario, ruta)
          )
        ''');
      },
    );
  }

  /// Serializa escrituras de captura y cambios de estado.
  Future<T> _ordenar<T>(Future<T> Function() fn) {
    final completer = Completer<T>();

    _local = _local.then((_) async {
      try {
        completer.complete(await fn());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });

    return completer.future;
  }

  String _uuid() {
    final random = Random.secure();

    final bytes = List.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;

    final hex = bytes.map((n) => n.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  Map<String, dynamic> _map(Object? value) {
    return Map<String, dynamic>.from(value as Map);
  }

  Object? _canon(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();

      return {for (final key in keys) key: _canon(value[key])};
    }

    if (value is List) {
      return value.map(_canon).toList();
    }

    return value;
  }

  int _usuario() {
    return _owner ?? (throw StateError('No hay una sesión activa.'));
  }

  void informar(String texto) {
    mensaje = texto;
    notifyListeners();
  }

  void _seguro(Future<void> Function() fn) {
    unawaited(() async {
      try {
        await fn();
      } catch (error) {
        informar(error.toString());
      }
    }());
  }

  Future<Map<String, dynamic>?> _contexto(
    DatabaseExecutor db,
    int usuario,
  ) async {
    final rows = await db.query(
      'contexto',
      where: 'usuario=?',
      whereArgs: [usuario],
    );

    if (rows.isEmpty || rows.first['documento'] == null) {
      return null;
    }

    return _map(jsonDecode(rows.first['documento'] as String));
  }

  Future<void> _guardarContexto(
    DatabaseExecutor db,
    int usuario,
    Object? documento,
  ) async {
    await db.insert('contexto', {
      'usuario': usuario,
      'documento': documento == null ? null : jsonEncode(documento),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    if (documento != null) {
      final doc = _map(documento);

      await db.insert('cache', {
        'usuario': usuario,
        'ruta': 'equipo:${doc['id_recorrido']}',
        'documento': jsonEncode(doc),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<bool> _hayAcciones(DatabaseExecutor db, int usuario) async {
    final rows = await db.rawQuery(
      "SELECT seq FROM cola "
      "WHERE usuario=? AND estado!='enviado' "
      "AND tipo IN ('pausar','reanudar','finalizar') "
      "LIMIT 1",
      [usuario],
    );

    return rows.isNotEmpty;
  }

  Future<Resource<ApiResponse<T>>> _recurso<T>(
    Future<Resource<ApiResponse<T>>> Function() fn,
  ) async {
    try {
      return await fn();
    } on _Fallo catch (error) {
      return ErrorData(message: error.mensaje, statusCode: error.status);
    } catch (error) {
      return ErrorData(message: error.toString());
    }
  }

  Future<List<Map<String, dynamic>>> recorridosEquipo() async {
    final usuario = _usuario();
    final identidad = _identity;
    final db = await _db;

    try {
      final body = await consultar('/recorridos/mis-recorridos?limit=100');

      final datos = _map(body['data']);

      for (final item in datos['items'] as List) {
        if (_owner != usuario || _identity != identidad) {
          throw StateError('La sesión cambió.');
        }

        final doc = _map(item);

        await db.insert('cache', {
          'usuario': usuario,
          'ruta': 'equipo:${doc['id_recorrido']}',
          'documento': jsonEncode(doc),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (_) {
      // Se conservan el contexto y los recorridos guardados.
    }

    if (_owner != usuario || _identity != identidad) {
      throw StateError('La sesión cambió.');
    }

    final rows = await db.query(
      'cache',
      where: "usuario=? AND ruta LIKE 'equipo:%'",
      whereArgs: [usuario],
    );

    final docs = <String, Map<String, dynamic>>{};

    for (final row in rows) {
      final doc = _map(jsonDecode(row['documento'] as String));

      docs['${doc['id_recorrido']}'] = doc;
    }

    final actual = await _contexto(db, usuario);

    if (actual != null) {
      docs['${actual['id_recorrido']}'] = actual;
    }

    return docs.values
        .where(
          (doc) => [
            'EN_CURSO',
            'PAUSADO',
            'FINALIZADO',
          ].contains(doc['estado_recorrido']),
        )
        .toList()
      ..sort(
        (a, b) =>
            (b['id_recorrido'] as num).compareTo(a['id_recorrido'] as num),
      );
  }

  Future<List<Map<String, Object?>>> registrosEquipo(int id) async {
    return (await _db).query(
      'cola',
      where:
          "usuario=? AND recorrido=? "
          "AND tipo IN ('recoleccion','resultado-final')",
      whereArgs: [_usuario(), id],
      orderBy: 'seq ASC',
    );
  }

  Future<Resource<ApiResponse<Map<String, dynamic>>>> guardarResultadoFinal(
    int id,
    Map<String, dynamic> payload,
  ) {
    return _recurso(() async {
      final usuario = _usuario();
      final identidad = _identity;

      final clave = await _ordenar(() async {
        final db = await _db;

        return db.transaction((tx) async {
          if (_owner != usuario || _identity != identidad) {
            throw StateError('La sesión cambió.');
          }

          final rows = await tx.query(
            'cache',
            where: 'usuario=? AND ruta=?',
            whereArgs: [usuario, 'equipo:$id'],
          );

          final actual = await _contexto(tx, usuario);

          final doc = actual?['id_recorrido'] == id
              ? actual
              : rows.isEmpty
              ? null
              : _map(jsonDecode(rows.first['documento'] as String));

          if (doc == null ||
              ![
                'EN_CURSO',
                'PAUSADO',
                'FINALIZADO',
              ].contains(doc['estado_recorrido'])) {
            throw StateError('Primero consulta el recorrido asignado.');
          }

          // Evita poner el resultado delante del cierre
          // cuando ambas operaciones salen del conductor.
          if (doc['id_usuario_inicio'] == usuario &&
              doc['estado_recorrido'] != 'FINALIZADO') {
            throw StateError(
              'Finaliza el recorrido antes de registrar el resultado.',
            );
          }

          final anteriores = await tx.query(
            'cola',
            where:
                "usuario=? AND recorrido=? "
                "AND tipo='resultado-final'",
            whereArgs: [usuario, id],
          );

          if (anteriores.isNotEmpty) {
            throw StateError(
              'El resultado ya está guardado. '
              'Revisa su sincronización.',
            );
          }

          return _insertar(tx, usuario, id, 'resultado-final', payload);
        });
      });

      await _contar();

      _seguro(() => sincronizar(inmediata: true));

      return PendingOperation<ApiResponse<Map<String, dynamic>>>(
        clave: clave,
        message:
            'Resultado guardado. Espera confirmación '
            'del cierre y sincronización.',
      );
    });
  }

  // ========================================================
  // SESIÓN Y CICLO DE VIDA
  // ========================================================

  Future<void> vincular(SessionBloc bloc) async {
    if (_session != null) return;

    _session = bloc;

    WidgetsBinding.instance.addObserver(this);

    _sessionSub = bloc.stream.listen(_sesion);

    // Respaldo: permite reintentar si vuelve el acceso
    // al backend sin cambiar el tipo de red.
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _seguro(() => sincronizar());
    });

    await _db;

    _sesion(bloc.state);

    await _iniciarObservadorRed();
  }

  void _sesion(SessionState state) {
    if (state.status == SessionStatus.unauthenticated || state.isLoggingOut) {
      _identity = null;
      mensaje = null;

      _seguro(_detenerGPS);

      pendientes = 0;
      bloqueadas = 0;

      notifyListeners();
      return;
    }

    if (!state.isAuthenticated) return;

    final token = state.session!.accessToken;
    String sessionId = '';

    try {
      final payload = _map(
        jsonDecode(
          utf8.decode(
            base64Url.decode(base64Url.normalize(token.split('.')[1])),
          ),
        ),
      );

      sessionId = payload['session_id'].toString();
    } catch (_) {}

    final identidad = '${state.session!.usuario.idUsuario}:$sessionId';

    // Un refresh conserva la identidad del login.
    if (identidad == _identity) return;

    _identity = identidad;
    mensaje = null;

    _seguro(_detenerGPS);

    if (!_esOperativo) {
      _seguro(_contar);
      return;
    }

    // _seguro(() async {
    //   await activo();
    //   await sincronizar();
    // });
    _seguro(() async {
      await _revisarRed(forzar: true);
      await activo();
      await sincronizar();
    });
  }

  Future<void> desvincular() async {
    _identity = null;
    _session = null;

    _sincronizacionSolicitadaPara = null;
    _ultimaFirmaRed = null;
    _revisionRed++;

    _timer?.cancel();
    _timer = null;

    _reconexionTimer?.cancel();
    _reconexionTimer = null;

    await _redSub?.cancel();
    _redSub = null;

    await _sessionSub?.cancel();
    _sessionSub = null;

    WidgetsBinding.instance.removeObserver(this);

    await _detenerGPS();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _esOperativo) {
      _seguro(() async {
        await _revisarRed(forzar: true);
        await activo();
        await _ajustarGPS();
        await sincronizar();
      });
    }
  }

  // ========================================================
  // RECORRIDO: CONSULTA Y CACHÉ
  // ========================================================

  Future<Resource<ApiResponse<RecorridoDataModel?>>> activo() {
    return _recurso(() async {
      final usuario = _usuario();
      final identidad = _identity;
      final db = await _db;

      Map<String, dynamic>? documento;

      String texto = 'Recorrido consultado.';

      if (await _hayAcciones(db, usuario)) {
        documento = await _contexto(db, usuario);

        texto = 'Estado local; hay acciones pendientes de sincronización.';
      } else {
        try {
          final body = await _api(usuario, 'GET', '/recorridos/activo');

          documento = body['data'] == null ? null : _map(body['data']);

          await _ordenar(() async {
            if (_owner != usuario || _identity != identidad) {
              return;
            }

            // No sobrescribir una acción guardada mientras
            // la consulta esperaba la respuesta.
            if (await _hayAcciones(db, usuario)) {
              documento = await _contexto(db, usuario);
            } else {
              await _guardarContexto(db, usuario, documento);

              if (documento != null) {
                await db.delete(
                  'cache',
                  where: 'usuario=? AND ruta=?',
                  whereArgs: [
                    usuario,
                    'inicio:${documento!['id_programacion']}',
                  ],
                );
              }
            }
          });
        } on _Fallo catch (error) {
          if (error.status != 0 && error.status < 500) {
            rethrow;
          }

          final rows = await db.query(
            'contexto',
            where: 'usuario=?',
            whereArgs: [usuario],
          );

          if (rows.isEmpty) rethrow;

          documento = await _contexto(db, usuario);

          texto =
              'Datos guardados en este dispositivo; '
              'sin confirmación reciente.';
        }
      }

      if (_owner != usuario || _identity != identidad) {
        throw StateError('La sesión cambió.');
      }

      await _ajustarGPS();

      final tieneActivo =
          documento != null &&
          ['EN_CURSO', 'PAUSADO'].contains(documento!['estado_recorrido']);

      return Success(
        ApiResponse<RecorridoDataModel?>(
          success: true,
          message: texto,
          data: tieneActivo ? RecorridoDataModel.fromJson(documento!) : null,
        ),
      );
    });
  }

  // ========================================================
  // DETECCIÓN DE CAMBIOS DE RED
  // ========================================================

  Future<void> _iniciarObservadorRed() async {
    if (_redSub != null) return;

    // Suscribir antes de consultar el estado inicial.
    _redSub = _connectivity.onConnectivityChanged.listen(
      (redes) {
        _revisionRed++;
        _procesarCambioRed(redes);
      },

      onError: (Object error) {
        // El temporizador de sincronización sigue funcionando.
        debugPrint('[OFFLINE] No se pudo observar la red: $error');
      },
    );

    await _revisarRed(forzar: true);
  }

  Future<void> _revisarRed({bool forzar = false}) async {
    final revision = _revisionRed;

    try {
      final redes = await _connectivity.checkConnectivity();

      if (_session == null || revision != _revisionRed) {
        return;
      }

      _procesarCambioRed(redes, forzar: forzar);
    } catch (error) {
      // Un fallo del observador no cancela los reintentos HTTP.
      debugPrint('[OFFLINE] No se pudo consultar la red: $error');
    }
  }

  void _procesarCambioRed(
    List<ConnectivityResult> redes, {
    bool forzar = false,
  }) {
    if (_session == null) return;

    final tipos = redes.map((red) => red.index).toSet().toList()..sort();

    final firma = tipos.join(',');

    if (!forzar && firma == _ultimaFirmaRed) {
      return;
    }

    _ultimaFirmaRed = firma;

    // Cancelar una solicitud anterior si la red vuelve a cambiar.
    _reconexionTimer?.cancel();

    final hayRed = redes.any((red) => red != ConnectivityResult.none);

    if (!hayRed) {
      debugPrint('[OFFLINE] Sin red. Se conservan los pendientes.');

      return;
    }

    // Dar un momento para que la nueva conexión se estabilice.
    _reconexionTimer = Timer(const Duration(seconds: 1), () {
      if (_session == null || _owner == null || !_esOperativo) {
        return;
      }

      debugPrint(
        '[OFFLINE] Red detectada. '
        'Solicitando sincronización automática.',
      );

      _seguro(() => sincronizar(inmediata: true));
    });
  }

  // ========================================================
  // INICIAR: REQUIERE CONFIRMACIÓN ONLINE
  // ========================================================

  Future<Resource<ApiResponse<RecorridoDataModel>>> iniciar(
    int idProgramacion,
    Map<String, dynamic> payload,
  ) {
    return _recurso(() async {
      if (_session?.state.user?.esConductor != true) {
        throw StateError('Solo el conductor puede iniciar el recorrido.');
      }

      final usuario = _usuario();
      final identidad = _identity;

      if ((await pendientesUsuario()).isNotEmpty) {
        throw StateError(
          'Sincroniza las operaciones anteriores antes '
          'de iniciar otro recorrido.',
        );
      }

      await _permisos(solicitar: true);

      final db = await _db;
      final intento = 'inicio:$idProgramacion';

      // Mantener la clave si el servidor inicia el recorrido
      // pero se pierde su respuesta.
      final cuerpo = await _ordenar(
        () => db.transaction((tx) async {
          final otros = await tx.query(
            'cache',
            where: "usuario=? AND ruta LIKE 'inicio:%' AND ruta!=?",
            whereArgs: [usuario, intento],
          );

          if (otros.isNotEmpty) {
            throw StateError(
              'Hay un inicio anterior pendiente de confirmar. '
              'Actualiza el recorrido activo.',
            );
          }

          final rows = await tx.query(
            'cache',
            where: 'usuario=? AND ruta=?',
            whereArgs: [usuario, intento],
          );

          if (rows.isNotEmpty) {
            return _map(jsonDecode(rows.first['documento'] as String));
          }

          final original = {
            ...payload,
            'clave_idempotencia': payload['clave_idempotencia'] ?? _uuid(),
          };

          await tx.insert('cache', {
            'usuario': usuario,
            'ruta': intento,
            'documento': jsonEncode(original),
          });

          return original;
        }),
      );

      if (_owner != usuario || _identity != identidad) {
        throw StateError('La sesión cambió.');
      }

      Map<String, dynamic> body;

      try {
        body = await _api(
          usuario,
          'POST',
          '/recorridos/iniciar/$idProgramacion',
          cuerpo,
        );
      } on _Fallo catch (error) {
        if ([400, 403, 404, 409, 422].contains(error.status)) {
          await db.delete(
            'cache',
            where: 'usuario=? AND ruta=?',
            whereArgs: [usuario, intento],
          );
        }

        rethrow;
      }

      final documento = _map(body['data']);

      await _ordenar(
        () => db.transaction((tx) async {
          await _guardarContexto(tx, usuario, documento);

          await tx.delete(
            'cache',
            where: 'usuario=? AND ruta=?',
            whereArgs: [usuario, intento],
          );
        }),
      );

      await _ajustarGPS();

      return Success(
        ApiResponse<RecorridoDataModel>(
          success: true,
          message: body['message'].toString(),
          data: RecorridoDataModel.fromJson(documento),
        ),
      );
    });
  }

  // ========================================================
  // GUARDAR GPS / RECOLECCIÓN
  // ========================================================

  Future<Resource<ApiResponse<T>>> guardar<T>(
    String tipo,
    Map<String, dynamic> payload,
  ) {
    return _recurso(() async {
      final usuario = _usuario();
      final identidad = _identity;

      final clave = await _ordenar(() async {
        final db = await _db;

        return db.transaction((tx) async {
          if (_owner != usuario || _identity != identidad) {
            throw StateError('La sesión cambió.');
          }

          final documento = await _contexto(tx, usuario);

          final id = (payload['id_recorrido'] as num).toInt();

          if (documento == null ||
              documento['id_recorrido'] != id ||
              documento['estado_recorrido'] != 'EN_CURSO') {
            throw StateError(
              'El recorrido no está en curso '
              'en este dispositivo.',
            );
          }

          return _insertar(tx, usuario, id, tipo, payload);
        });
      });

      _seguro(_contar);
      unawaited(sincronizar());

      return PendingOperation<ApiResponse<T>>(
        clave: clave,
        message:
            'Guardado en el dispositivo. '
            'Pendiente de sincronización.',
      );
    });
  }

  Future<Resource<ApiResponse<T>>> guardarLote<T>(
    String tipo,
    int idRecorrido,
    List<Map<String, dynamic>> items,
  ) {
    return _recurso(() async {
      if (items.isEmpty) {
        throw StateError('El lote está vacío.');
      }

      final usuario = _usuario();
      final identidad = _identity;

      final claves = await _ordenar(() async {
        final db = await _db;

        return db.transaction((tx) async {
          if (_owner != usuario || _identity != identidad) {
            throw StateError('La sesión cambió.');
          }

          final documento = await _contexto(tx, usuario);

          if (documento == null ||
              documento['id_recorrido'] != idRecorrido ||
              documento['estado_recorrido'] != 'EN_CURSO') {
            throw StateError('El recorrido no está en curso.');
          }

          final claves = <String>[];

          for (final item in items) {
            claves.add(
              await _insertar(tx, usuario, idRecorrido, tipo, {
                ...item,
                'id_recorrido': idRecorrido,
              }),
            );
          }

          return claves;
        });
      });

      _seguro(_contar);
      unawaited(sincronizar());

      return PendingOperation<ApiResponse<T>>(
        clave: claves.first,
        message: '${claves.length} registros guardados localmente.',
      );
    });
  }

  Future<String> _insertar(
    DatabaseExecutor tx,
    int usuario,
    int idRecorrido,
    String tipo,
    Map<String, dynamic> payload,
  ) async {
    final clave = payload['clave_idempotencia']?.toString() ?? _uuid();

    if (clave.length < 8 || clave.length > 100) {
      throw StateError(
        'La clave de idempotencia debe tener '
        'entre 8 y 100 caracteres.',
      );
    }

    final contenido = jsonEncode(
      _canon({...payload, 'clave_idempotencia': clave}),
    );

    final anterior = await tx.query(
      'cola',
      where: 'clave=?',
      whereArgs: [clave],
    );

    if (anterior.isNotEmpty) {
      if (anterior.first['usuario'] != usuario ||
          anterior.first['tipo'] != tipo ||
          anterior.first['payload'] != contenido) {
        throw StateError(
          'La clave ya pertenece a otra operación '
          'o contenido.',
        );
      }

      return clave;
    }

    if (tipo == 'recoleccion' || tipo == 'gps') {
      final resultado = await tx.query(
        'cola',
        where:
            "usuario=? AND recorrido=? "
            "AND tipo='resultado-final'",
        whereArgs: [usuario, idRecorrido],
        limit: 1,
      );

      if (resultado.isNotEmpty) {
        throw StateError('El resultado final ya está guardado.');
      }
    }

    if (tipo == 'recoleccion') {
      final registros = await tx.query(
        'cola',
        where:
            "usuario=? AND recorrido=? "
            "AND tipo='recoleccion' AND estado!='enviado'",
        whereArgs: [usuario, idRecorrido],
      );

      final puntoPendiente = registros.any((registro) {
        final datos = _map(jsonDecode(registro['payload'] as String));

        return datos['id_ruta_punto'] == payload['id_ruta_punto'];
      });

      if (puntoPendiente) {
        throw StateError(
          'Este punto ya tiene una recolección '
          'pendiente de sincronizar.',
        );
      }
    }

    await tx.insert('cola', {
      'clave': clave,
      'usuario': usuario,
      'recorrido': idRecorrido,
      'tipo': tipo,
      'payload': contenido,
    });

    return clave;
  }

  // ========================================================
  // PAUSA / REANUDACIÓN / FINALIZACIÓN
  // ========================================================

  Future<Resource<ApiResponse<RecorridoDataModel>>> cambiar(
    int idRecorrido,
    String tipo,
    Map<String, dynamic> payload,
  ) {
    return _recurso(() async {
      if (_session?.state.user?.esConductor != true) {
        throw StateError('Solo el conductor controla el recorrido.');
      }

      if (!_acciones.contains(tipo)) {
        throw ArgumentError('Acción no válida.');
      }

      final usuario = _usuario();
      final identidad = _identity;

      // Evitar nuevas muestras al pausar o finalizar.
      await _detenerGPS();

      try {
        final resultado = await _ordenar(() async {
          final db = await _db;

          return db.transaction((tx) async {
            if (_owner != usuario || _identity != identidad) {
              throw StateError('La sesión cambió.');
            }

            final documento = await _contexto(tx, usuario);

            if (documento == null || documento['id_recorrido'] != idRecorrido) {
              throw StateError('Actualiza el recorrido activo.');
            }

            final estado = documento['estado_recorrido'];

            final noPermitida =
                (tipo == 'reanudar' && estado != 'PAUSADO') ||
                (tipo == 'pausar' && estado != 'EN_CURSO') ||
                (tipo == 'finalizar' &&
                    !['EN_CURSO', 'PAUSADO'].contains(estado));

            if (documento['id_usuario_inicio'] != usuario) {
              throw StateError(
                'Solo el conductor que inició el recorrido '
                'puede controlarlo.',
              );
            }

            if (noPermitida) {
              throw StateError(
                'La acción no corresponde '
                'al estado local del recorrido.',
              );
            }

            final fecha =
                payload['fecha_evento'] ??
                DateTime.now().toUtc().toIso8601String();

            final clave = await _insertar(tx, usuario, idRecorrido, tipo, {
              ...payload,
              'fecha_evento': fecha,
            });

            documento['estado_recorrido'] = tipo == 'pausar'
                ? 'PAUSADO'
                : tipo == 'reanudar'
                ? 'EN_CURSO'
                : 'FINALIZADO';

            if (tipo == 'finalizar') {
              documento['fecha_hora_finalizacion'] = fecha;
            }

            // La acción y su proyección local se guardan juntas.
            await _guardarContexto(tx, usuario, documento);

            return PendingOperation<ApiResponse<RecorridoDataModel>>(
              clave: clave,
              message:
                  'Acción guardada localmente. '
                  'Pendiente de sincronización.',
              data: ApiResponse(
                success: true,
                message: 'Estado local pendiente.',
                data: RecorridoDataModel.fromJson(documento),
              ),
            );
          });
        });

        await _contar();
        unawaited(sincronizar());

        return resultado;
      } finally {
        await _ajustarGPS();
      }
    });
  }

  // ========================================================
  // CONSULTAR Y REINTENTAR PENDIENTES
  // ========================================================

  Future<List<Map<String, Object?>>> pendientesUsuario() async {
    final usuario = _owner;

    if (usuario == null) return [];

    return (await _db).query(
      'cola',
      where: "usuario=? AND estado!='enviado'",
      whereArgs: [usuario],
      orderBy: 'seq ASC',
    );
  }

  Future<void> _contar() async {
    final usuario = _owner;

    if (usuario == null) {
      pendientes = 0;
      bloqueadas = 0;
      notifyListeners();
      return;
    }

    final rows = await (await _db).rawQuery(
      "SELECT COUNT(*) total, "
      "SUM(CASE WHEN estado='bloqueado' THEN 1 ELSE 0 END) "
      "bloqueadas FROM cola "
      "WHERE usuario=? AND estado!='enviado'",
      [usuario],
    );

    pendientes = (rows.first['total'] as num).toInt();

    bloqueadas = (rows.first['bloqueadas'] as num?)?.toInt() ?? 0;

    notifyListeners();
  }

  Future<void> reintentar(int seq) async {
    await (await _db).update(
      'cola',
      {'estado': 'pendiente', 'proximo': 0, 'error': null},
      where: "seq=? AND usuario=? AND estado!='enviado'",
      whereArgs: [seq, _usuario()],
    );

    await _contar();
    await sincronizar();
    await _ajustarGPS();
  }

  // ========================================================
  // SINCRONIZACIÓN FIFO
  // ========================================================

  Future<void> sincronizar({bool inmediata = false}) async {
    if (_owner == null || !_esOperativo) {
      return;
    }

    if (_syncing) {
      if (inmediata) {
        _sincronizacionSolicitadaPara = _identity;
      }

      return;
    }

    _syncing = true;

    final usuario = _usuario();
    final identidad = _identity;

    notifyListeners();

    try {
      final db = await _db;

      if (inmediata) {
        // Recuperamos red: adelantar los reintentos temporales.
        // No modificar operaciones bloqueadas ni confirmadas.
        await db.update(
          'cola',

          {'proximo': 0},

          where: "usuario=? AND estado='pendiente'",
          whereArgs: [usuario],
        );
      }

      for (var i = 0; i < 100; i++) {
        if (_owner != usuario || _identity != identidad) {
          break;
        }

        final rows = await db.query(
          'cola',

          where: "usuario=? AND estado!='enviado'",
          whereArgs: [usuario],

          orderBy: 'seq ASC',
          limit: 1,
        );

        if (rows.isEmpty) {
          break;
        }

        final registro = rows.first;

        if (registro['estado'] == 'bloqueado') {
          // No adelantar otras operaciones sobre un rechazo.
          break;
        }

        if ((registro['proximo'] as int) >
            DateTime.now().millisecondsSinceEpoch) {
          break;
        }

        final tipo = registro['tipo'] as String;
        final esAccion = _acciones.contains(tipo);

        final ruta = tipo == 'resultado-final'
            ? '/recorridos/${registro['recorrido']}/resultado-final'
            : tipo == 'gps'
            ? '/tracking/ubicaciones'
            : tipo == 'recoleccion'
            ? '/recolecciones/register'
            : '/recorridos/$tipo/${registro['recorrido']}';

        // final ruta = tipo == 'gps'
        //     ? '/tracking/ubicaciones'
        //     : tipo == 'recoleccion'
        //     ? '/recolecciones/register'
        //     : '/recorridos/$tipo/${registro['recorrido']}';

        try {
          final respuesta = await _api(
            usuario,
            esAccion ? 'PATCH' : 'POST',
            ruta,

            _map(jsonDecode(registro['payload'] as String)),
          );

          if (respuesta['data'] is! Map) {
            throw const _Fallo(
              0,
              'El servidor no confirmó '
              'los datos de la operación.',
            );
          }

          await _ordenar(
            () => db.transaction((tx) async {
              await tx.update(
                'cola',

                {
                  'estado': 'enviado',
                  'error': null,
                  'respuesta': jsonEncode(respuesta),
                },

                where: 'seq=?',
                whereArgs: [registro['seq']],
              );

              // Conservar cualquier proyección local posterior.
              if (esAccion && !await _hayAcciones(tx, usuario)) {
                await _guardarContexto(tx, usuario, respuesta['data']);
              }
            }),
          );

          mensaje = null;

          if (esAccion && _owner == usuario && _identity == identidad) {
            onRecorridoSincronizado?.call();
          }
        } on _Fallo catch (error) {
          final temporal =
              error.status == 0 ||
              error.status == 401 ||
              error.status == 408 ||
              error.status == 425 ||
              error.status == 429 ||
              error.status >= 500;

          final intentos = (registro['intentos'] as int) + 1;

          final segundos = min(300, 5 * pow(2, min(intentos - 1, 6)).toInt());

          await db.update(
            'cola',

            {
              'estado': temporal ? 'pendiente' : 'bloqueado',

              'intentos': intentos,

              'proximo':
                  DateTime.now().millisecondsSinceEpoch + segundos * 1000,

              'error': error.mensaje,
            },

            where: 'seq=?',
            whereArgs: [registro['seq']],
          );

          mensaje = error.mensaje;

          if (!temporal) {
            await _detenerGPS();

            if (_owner == usuario && _identity == identidad) {
              onRecorridoSincronizado?.call();
            }
          }

          break;
        }
      }
    } catch (error) {
      mensaje = 'No se pudo sincronizar: $error';
    } finally {
      final siguiente = _sincronizacionSolicitadaPara;

      _sincronizacionSolicitadaPara = null;
      _syncing = false;

      try {
        await _contar();
      } catch (error) {
        informar('No se pudo consultar el estado de la cola: $error');
      }

      // Una reconexión pudo ocurrir durante el envío.
      // Atenderla después, conservando una sola ejecución.
      if (siguiente != null &&
          siguiente == _identity &&
          _owner != null &&
          _esOperativo) {
        _seguro(() => sincronizar(inmediata: true));
      }
    }
  }

  // ========================================================
  // HTTP CON RENOVACIÓN COMPARTIDA
  // ========================================================

  Future<Map<String, dynamic>> _api(
    int usuario,
    String metodo,
    String ruta, [
    Map<String, dynamic>? payload,
  ]) async {
    final identidad = _identity;

    if (_owner != usuario) {
      throw const _Fallo(
        401,
        'La sesión no corresponde al propietario de la cola.',
      );
    }

    Future<http.Response> enviar(String token) async {
      final base = Environment.mainUrl.replaceAll(RegExp(r'/+$'), '');

      final request = http.Request(metodo, Uri.parse('$base$ruta'));

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'x-client-origin': 'APP',
      });

      if (payload != null) {
        request.body = jsonEncode(payload);
      }

      final client = http.Client();

      try {
        return await (() async {
          return http.Response.fromStream(await client.send(request));
        })().timeout(const Duration(seconds: 20));
      } finally {
        client.close();
      }
    }

    try {
      var token = await _session!.tokenParaOperacion();

      if (token == null) {
        throw const _Fallo(0, 'La sincronización espera una sesión renovada.');
      }

      if (_owner != usuario || _identity != identidad) {
        throw const _Fallo(401, 'La sesión cambió.');
      }

      var response = await enviar(token);

      if (response.statusCode == 401) {
        final actual = _session!.state.session?.accessToken;

        token = actual != null && actual != token
            ? actual
            : await _session!.tokenParaOperacion(forzar: true);

        if (token == null) {
          throw const _Fallo(401, 'No se pudo renovar la sesión.');
        }

        if (_owner != usuario || _identity != identidad) {
          throw const _Fallo(401, 'La sesión cambió.');
        }

        response = await enviar(token);
      }

      if (_owner != usuario || _identity != identidad) {
        throw const _Fallo(401, 'La sesión cambió durante el envío.');
      }

      Map<String, dynamic> body;

      try {
        body = _map(jsonDecode(response.body));
      } catch (_) {
        throw _Fallo(
          response.statusCode >= 400 ? response.statusCode : 0,
          'El servidor devolvió una respuesta no válida.',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['success'] != true) {
        throw _Fallo(
          response.statusCode >= 400 ? response.statusCode : 422,
          body['message']?.toString() ?? 'Operación rechazada.',
        );
      }

      return body;
    } on _Fallo {
      rethrow;
    } catch (_) {
      throw const _Fallo(
        0,
        'Sin conexión o tiempo de espera agotado. '
        'Los datos siguen guardados.',
      );
    }
  }

  // ========================================================
  // CACHÉ DE CONSULTAS OPERATIVAS
  // ========================================================

  Future<Map<String, dynamic>> consultar(String ruta) async {
    final usuario = _usuario();
    final db = await _db;

    try {
      final body = await _api(usuario, 'GET', ruta);

      await db.insert('cache', {
        'usuario': usuario,
        'ruta': ruta,
        'documento': jsonEncode(body),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return body;
    } on _Fallo catch (error) {
      if (error.status != 0 && error.status < 500) {
        rethrow;
      }

      final rows = await db.query(
        'cache',
        where: 'usuario=? AND ruta=?',
        whereArgs: [usuario, ruta],
      );

      if (rows.isEmpty) rethrow;

      return {
        ..._map(jsonDecode(rows.first['documento'] as String)),
        'message': 'Información almacenada en el dispositivo.',
      };
    }
  }

  // ========================================================
  // GPS OPERATIVO
  // ========================================================

  Future<void> _permisos({bool solicitar = false}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('Esta operación está configurada para Android.');
    }

    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      throw StateError('Activa el GPS.');
    }

    var permiso = await geo.Geolocator.checkPermission();

    if (solicitar && permiso == geo.LocationPermission.denied) {
      permiso = await geo.Geolocator.requestPermission();
    }

    if (![
      geo.LocationPermission.whileInUse,
      geo.LocationPermission.always,
    ].contains(permiso)) {
      throw StateError('Concede el permiso de ubicación.');
    }
  }

  Future<void> _detenerGPS() async {
    _gpsVersion++;
    _gpsRoute = null;
    _ultimaMuestra = null;

    final subscription = _gps;
    _gps = null;

    await subscription?.cancel();

    notifyListeners();
  }

  Future<void> _ajustarGPS() {
    _sensor = _sensor
        .then((_) async {
          final usuario = _owner;

          if (usuario == null) {
            await _detenerGPS();
            return;
          }

          final documento = await _contexto(await _db, usuario);

          final idRecorrido = (documento?['id_recorrido'] as num?)?.toInt();

          final tieneBloqueadas = (await pendientesUsuario()).any(
            (registro) => registro['estado'] == 'bloqueado',
          );

          if (documento == null ||
              documento['estado_recorrido'] != 'EN_CURSO' ||
              _session!.state.session?.usuario.esConductor != true ||
              documento['id_usuario_inicio'] != usuario ||
              tieneBloqueadas) {
            await _detenerGPS();
            return;
          }

          if (_gps != null && _gpsRoute == idRecorrido) {
            return;
          }

          final lifecycle = WidgetsBinding.instance.lifecycleState;

          // Iniciar el servicio cuando la app esté visible.
          // Si ya estaba iniciado, el retorno anterior lo conserva.
          if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
            informar(
              'Abre la aplicación para iniciar '
              'o recuperar el seguimiento GPS.',
            );

            return;
          }

          await _detenerGPS();

          final version = _gpsVersion;
          final identidad = _identity;

          await _permisos();

          if (version != _gpsVersion ||
              _owner != usuario ||
              _identity != identidad) {
            return;
          }

          _gpsRoute = idRecorrido;

          _gps =
              geo.Geolocator.getPositionStream(
                locationSettings: geo.AndroidSettings(
                  accuracy: geo.LocationAccuracy.high,
                  distanceFilter: 0,
                  intervalDuration: const Duration(seconds: 10),

                  foregroundNotificationConfig:
                      const geo.ForegroundNotificationConfig(
                        notificationTitle: 'Recolección en curso',
                        notificationText:
                            'La ubicación se guarda durante el recorrido.',
                        enableWakeLock: true,
                        setOngoing: true,
                      ),
                ),
              ).listen(
                (position) {
                  if (version != _gpsVersion ||
                      _owner != usuario ||
                      _identity != identidad ||
                      position.isMocked) {
                    return;
                  }

                  final edad = DateTime.now()
                      .toUtc()
                      .difference(position.timestamp.toUtc())
                      .inSeconds;

                  if (edad > 120 ||
                      edad < -5 ||
                      !position.latitude.isFinite ||
                      !position.longitude.isFinite) {
                    return;
                  }

                  final minimo =
                      position.speed.isFinite &&
                          position.speed >= 0 &&
                          position.speed < 0.5
                      ? 30
                      : 10;

                  if (_ultimaMuestra != null &&
                      position.timestamp.difference(_ultimaMuestra!).inSeconds <
                          minimo) {
                    return;
                  }

                  _ultimaMuestra = position.timestamp;

                  final payload = <String, dynamic>{
                    'id_recorrido': idRecorrido,

                    // La misma muestra conserva su identidad.
                    'clave_idempotencia':
                        'gps-$usuario-$idRecorrido-'
                        '${position.timestamp.toUtc().microsecondsSinceEpoch}',

                    'latitud': position.latitude,
                    'longitud': position.longitude,

                    if (position.accuracy.isFinite && position.accuracy >= 0)
                      'precision_gps': position.accuracy,

                    if (position.altitude.isFinite)
                      'altitud': position.altitude,

                    if (position.speed.isFinite && position.speed >= 0)
                      'velocidad_mps': position.speed,

                    if (position.heading.isFinite && position.heading >= 0)
                      'rumbo': position.heading % 360,

                    'fecha_dispositivo': position.timestamp
                        .toUtc()
                        .toIso8601String(),

                    'es_ubicacion_simulada': false,
                  };

                  _seguro(() async {
                    final resultado =
                        await guardar<RegistrarUbicacionDataModel>(
                          'gps',
                          payload,
                        );

                    if (resultado
                        is ErrorData<
                          ApiResponse<RegistrarUbicacionDataModel>
                        >) {
                      await _detenerGPS();

                      throw StateError(resultado.message);
                    }
                  });
                },

                onError: (Object error) {
                  informar('El seguimiento GPS se interrumpió: $error');

                  _seguro(_detenerGPS);
                },
              );

          notifyListeners();
        })
        .catchError((Object error) {
          informar(error.toString());
        });

    return _sensor;
  }
}

class _Fallo implements Exception {
  final int status;
  final String mensaje;

  const _Fallo(this.status, this.mensaje);

  @override
  String toString() => mensaje;
}
