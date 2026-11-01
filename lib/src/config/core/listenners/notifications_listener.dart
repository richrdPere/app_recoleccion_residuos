import 'dart:async';
import 'dart:convert';

import 'package:app_recoleccion_residuos/src/data/datasources/local/services/local_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_state.dart';
import 'package:app_recoleccion_residuos/src/config/router/app_router.dart';
import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_cubit.dart';

class NotificationsListener extends StatefulWidget {
  final Widget child;
  final NotificacionesUseCases useCases;

  const NotificationsListener({
    super.key,
    required this.child,
    required this.useCases,
  });

  @override
  State<NotificationsListener> createState() => _NotificationsListenerState();
}

class _NotificationsListenerState extends State<NotificationsListener>
    with WidgetsBindingObserver {
  final _local = LocalNotificationsService.instance;
  final Set<String> _shown = {};

  StreamSubscription<RemoteMessage>? _foreground;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<String>? _taps;

  Timer? _poll;

  _PendingOpen? _pending;

  String? _lastUser;

  bool _scheduled = false;
  bool _navigating = false;

  Future<void> _presentation = Future<void>.value();

  String? get _user {
    final session = context.read<SessionBloc>().state;

    return session.isAuthenticated
        ? session.session!.usuario.idUsuario.toString()
        : null;
  }

  bool get _resumed {
    final lifecycle = WidgetsBinding.instance.lifecycleState;

    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _foreground = FirebaseMessaging.onMessage.listen((message) {
      unawaited(_receive(message));
    });

    _opened = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _queue(message.data),
    );

    _taps = _local.onTap.listen(_localTap);

    appRouter.routerDelegate.addListener(_scheduleNavigation);

    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted || !_resumed || _user == null) {
        return;
      }

      _refreshInbox();
      _scheduleNavigation();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _sessionChanged(context.read<SessionBloc>().state);

      unawaited(_initial());
    });
  }

  void _refreshInbox({bool forceList = false}) {
    if (!mounted || _user == null) return;

    final cubit = context.read<NotificacionesCubit>();

    unawaited(cubit.refreshCount());

    final path = appRouter.routerDelegate.currentConfiguration.uri.path;

    final isInbox = path == '/notificaciones' || path == '/ciudadano/alertas';

    // No perder páginas adicionales cargadas durante el polling.
    final canRefreshList = forceList || cubit.state.page <= 1;

    if (isInbox &&
        canRefreshList &&
        !cubit.state.loading &&
        !cubit.state.loadingMore) {
      unawaited(cubit.refresh());
    }
  }

  Future<void> _receive(RemoteMessage message) async {
    final user = _user;

    final id = int.tryParse('${message.data['id_notificacion_usuario'] ?? ''}');

    if (user == null || id == null || id <= 0) return;

    _refreshInbox(forceList: true);

    final key = '$user:$id';

    if (!_shown.add(key)) return;

    try {
      final result = await widget.useCases.getNotificacionById.run(id: id);

      if (!mounted || _user != user) return;

      if (result is! Success<ApiResponse<GetNotificacionByIdDataModel>>) {
        _shown.remove(key);
        return;
      }

      final item = result.data.data;

      if (item == null || item.idUsuario.toString() != user) {
        return;
      }

      _presentation = _presentation
          .then<void>((_) async {
            if (!mounted || _user != user) return;

            await _local.show(
              idNotificacionUsuario: id,
              userId: user,
              title: item.notificacion.titulo,
              body: item.notificacion.mensaje,
            );
          })
          .catchError((Object error, StackTrace stack) {
            _shown.remove(key);
            debugPrint('[notificaciones:local] $error');
          });

      await _presentation;

      if (_shown.length > 200) {
        _shown.remove(_shown.first);
      }
    } catch (error) {
      _shown.remove(key);
      debugPrint('[notificaciones:recepcion] $error');
    }
  }

  Future<void> _initial() async {
    try {
      final localPayload = _local.takeInitialPayload();

      if (localPayload != null) {
        _localTap(localPayload);
      }

      final message = await FirebaseMessaging.instance.getInitialMessage();

      if (mounted && message != null) {
        _queue(message.data);
      }
    } catch (error) {
      debugPrint('[notificaciones:inicial] $error');
    }
  }

  void _localTap(String payload) {
    try {
      final value = jsonDecode(payload);

      if (value is Map) {
        _queue(Map<String, dynamic>.from(value));
      }
    } catch (_) {
      debugPrint('[notificaciones] Payload local inválido.');
    }
  }

  void _queue(Map<String, dynamic> data) {
    if (!mounted) return;

    final id = int.tryParse('${data['id_notificacion_usuario'] ?? ''}');

    if (id == null || id <= 0) return;

    _pending = _PendingOpen(id, data['id_usuario']?.toString());

    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    if (!mounted || _scheduled || _pending == null) {
      return;
    }

    _scheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;

      if (mounted) {
        unawaited(_navigate());
      }
    });

    WidgetsBinding.instance.ensureVisualUpdate();
  }

  bool _blockedPath(String path) {
    return authFlowRoutes.contains(path) ||
        publicRoutes.contains(path) ||
        path == '/ciudadano/acceso' ||
        path == '/sin-acceso';
  }

  Future<void> _navigate() async {
    final user = _user;
    final pending = _pending;

    if (_navigating || user == null || pending == null || !_resumed) {
      return;
    }

    final path = appRouter.routerDelegate.currentConfiguration.uri.path;

    if (_blockedPath(path)) return;

    if (rootNavigatorKey.currentState?.overlay == null) {
      return;
    }

    if (pending.owner != null && pending.owner != user) {
      _pending = null;
      return;
    }

    _navigating = true;

    try {
      final result = await widget.useCases.getNotificacionById.run(
        id: pending.id,
      );

      if (!mounted || _user != user || !identical(_pending, pending)) {
        return;
      }

      if (result is ErrorData<ApiResponse<GetNotificacionByIdDataModel>>) {
        if (result.statusCode == 403 || result.statusCode == 404) {
          _pending = null;
        }

        return;
      }

      if (result is! Success<ApiResponse<GetNotificacionByIdDataModel>>) {
        return;
      }

      final item = result.data.data;

      if (item == null || item.idUsuario.toString() != user) {
        _pending = null;
        return;
      }

      if (!_resumed) return;

      final current = appRouter.routerDelegate.currentConfiguration.uri.path;

      if (_blockedPath(current)) return;

      final roles = getSessionRoles(context.read<SessionBloc>().state);

      final citizen =
          current.startsWith('/ciudadano/') ||
          (roles.contains('CIUDADANO') &&
              !roles.any(operationalRoles.contains));

      final area = citizen ? 'ciudadano' : 'operativo';

      final destination = '/notificaciones/${pending.id}?area=$area';

      _pending = null;

      if (current != '/notificaciones/${pending.id}') {
        unawaited(appRouter.push<void>(destination).then<void>((_) {}));
      }

      _refreshInbox();
    } catch (error) {
      debugPrint('[notificaciones:navegacion] $error');
    } finally {
      _navigating = false;

      if (mounted && _pending != null && !identical(_pending, pending)) {
        _scheduleNavigation();
      }
    }
  }

  void _sessionChanged(SessionState session) {
    final cubit = context.read<NotificacionesCubit>();

    if (session.isAuthenticated) {
      final user = session.session!.usuario.idUsuario.toString();

      if (_lastUser != user) {
        if (_lastUser != null) {
          _pending = null;
        }

        _shown.clear();
        _lastUser = user;

        cubit.bindSession(user);

        _refreshInbox();
      }

      _scheduleNavigation();
      return;
    }

    if (session.status == SessionStatus.loggingOut ||
        session.status == SessionStatus.unauthenticated) {
      cubit.bindSession(null);

      if (_lastUser != null) {
        _pending = null;
        _shown.clear();

        _presentation = _presentation
            .then<void>((_) => _local.cancelAll())
            .catchError((Object error, StackTrace stack) {
              debugPrint('[notificaciones:limpieza] $error');
            });
      }

      _lastUser = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshInbox(forceList: true);
      _scheduleNavigation();
    }
  }

  @override
  void dispose() {
    _poll?.cancel();

    _foreground?.cancel();
    _opened?.cancel();
    _taps?.cancel();

    appRouter.routerDelegate.removeListener(_scheduleNavigation);

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (_, session) => _sessionChanged(session),
      child: widget.child,
    );
  }
}

class _PendingOpen {
  final int id;
  final String? owner;

  const _PendingOpen(this.id, this.owner);
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:app_recoleccion_residuos/src/data/datasources/local/services/local_notification_service.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
// import 'package:app_recoleccion_residuos/src/config/core/session/session_state.dart';
// import 'package:app_recoleccion_residuos/src/config/router/app_router.dart';
// import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';

// import 'package:app_recoleccion_residuos/src/data/models/models.dart';
// import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
// import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// class NotificationsListener extends StatefulWidget {
//   final Widget child;
//   final NotificacionesUseCases useCases;

//   const NotificationsListener({
//     super.key,
//     required this.child,
//     required this.useCases,
//   });

//   @override
//   State<NotificationsListener> createState() => _NotificationsListenerState();
// }

// class _NotificationsListenerState extends State<NotificationsListener>
//     with WidgetsBindingObserver {
//   final _local = LocalNotificationsService.instance;

//   StreamSubscription<RemoteMessage>? _foregroundSubscription;
//   StreamSubscription<RemoteMessage>? _openedSubscription;
//   StreamSubscription<String>? _localTapSubscription;

//   Timer? _retryTimer;

//   final Set<String> _shown = {};
//   final Set<String> _opened = {};

//   _NotificationOpenRequest? _pending;

//   String? _lastUserId;
//   bool _opening = false;
//   bool _scheduled = false;

//   String? get _userId {
//     final state = context.read<SessionBloc>().state;

//     if (!state.isAuthenticated) return null;

//     return state.session!.usuario.idUsuario.toString();
//   }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);

//     _lastUserId = _userId;

//     _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
//       unawaited(_showForeground(message));
//     });

//     _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
//       message,
//     ) {
//       _queueOpen(message.data);
//     });

//     _localTapSubscription = _local.onTap.listen((payload) {
//       _openLocalPayload(payload);
//     });

//     appRouter.routerDelegate.addListener(_scheduleOpen);

//     // Si falló una consulta por falta de red, reintenta
//     // mientras exista una apertura pendiente.
//     _retryTimer = Timer.periodic(const Duration(seconds: 15), (_) {
//       if (_pending != null) {
//         _scheduleOpen();
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       unawaited(_readInitialNotifications());
//     });
//   }

//   // ==========================================================
//   // APP ABIERTA: VALIDAR Y MOSTRAR AVISO LOCAL
//   // ==========================================================

//   Future<void> _showForeground(RemoteMessage message) async {
//     final userId = _userId;

//     if (userId == null) return;

//     final id = _parseId(message.data['id_notificacion_usuario']);

//     if (id == null) return;

//     final key = '$userId:$id';

//     // Reservar antes del await evita procesamientos duplicados.
//     if (!_shown.add(key)) return;

//     try {
//       final detail = await _fetchDetail(id);

//       if (!mounted || _userId != userId) return;

//       if (detail == null) {
//         _shown.remove(key);
//         return;
//       }

//       // Defensa adicional frente a un cambio de cuenta.
//       if (detail.idUsuario.toString() != userId) return;

//       await _local.show(
//         idNotificacionUsuario: id,
//         userId: userId,
//         title: detail.notificacion.titulo,
//         body: detail.notificacion.mensaje,
//       );

//       if (_shown.length > 200) {
//         _shown.remove(_shown.first);
//       }
//     } catch (error) {
//       _shown.remove(key);
//       debugPrint('[notificaciones] Presentación fallida: $error');
//     }
//   }

//   // ==========================================================
//   // APERTURAS DESDE APP CERRADA
//   // ==========================================================

//   Future<void> _readInitialNotifications() async {
//     try {
//       final localPayload = _local.takeInitialPayload();

//       if (localPayload != null) {
//         _openLocalPayload(localPayload);
//       }

//       // Apertura desde una notificación remota de Firebase.
//       final message = await FirebaseMessaging.instance.getInitialMessage();

//       if (!mounted) return;

//       if (message != null) {
//         _queueOpen(message.data);
//       }
//     } catch (error) {
//       debugPrint('[notificaciones] Apertura inicial fallida: $error');
//     }
//   }

//   void _openLocalPayload(String payload) {
//     try {
//       final decoded = jsonDecode(payload);

//       if (decoded is Map) {
//         _queueOpen(Map<String, dynamic>.from(decoded));
//       }
//     } catch (_) {
//       debugPrint('[notificaciones] Payload local inválido.');
//     }
//   }

//   // ==========================================================
//   // ESPERAR SESIÓN Y NAVEGADOR
//   // ==========================================================

//   void _queueOpen(Map<String, dynamic> data) {
//     if (!mounted) return;

//     final id = _parseId(data['id_notificacion_usuario']);

//     if (id == null) return;

//     // Se conserva la apertura más reciente.
//     _pending = _NotificationOpenRequest(
//       id: id,
//       ownerId: data['id_usuario']?.toString(),
//     );

//     _scheduleOpen();
//   }

//   void _scheduleOpen() {
//     if (!mounted || _scheduled || _pending == null) return;

//     _scheduled = true;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scheduled = false;

//       if (mounted) {
//         unawaited(_tryOpen());
//       }
//     });

//     WidgetsBinding.instance.ensureVisualUpdate();
//   }

//   bool get _canOpen {
//     if (_userId == null) return false;

//     final lifecycle = WidgetsBinding.instance.lifecycleState;

//     if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
//       return false;
//     }

//     final path = appRouter.routerDelegate.currentConfiguration.uri.path;

//     if (authFlowRoutes.contains(path)) return false;

//     return rootNavigatorKey.currentState?.overlay != null;
//   }

//   Future<void> _tryOpen() async {
//     if (_opening || !_canOpen) return;

//     final request = _pending;
//     final userId = _userId;

//     if (request == null || userId == null) return;

//     if (request.ownerId != null && request.ownerId != userId) {
//       _pending = null;
//       return;
//     }

//     final key = '$userId:${request.id}';

//     if (_opened.contains(key)) {
//       _pending = null;
//       return;
//     }

//     _opening = true;

//     try {
//       final detail = await _fetchDetail(request.id);

//       if (!mounted || _userId != userId) return;

//       // Otra notificación pudo tocarse durante la consulta.
//       if (!identical(_pending, request)) return;

//       if (detail == null) {
//         _pending = null;
//         return;
//       }

//       if (detail.idUsuario.toString() != userId) {
//         _pending = null;
//         return;
//       }

//       if (!_canOpen) return;

//       final dialogContext = rootNavigatorKey.currentState!.overlay!.context;

//       _pending = null;
//       _opened.add(key);

//       if (_opened.length > 200) {
//         _opened.remove(_opened.first);
//       }

//       await showDialog<void>(
//         context: dialogContext,
//         useRootNavigator: true,
//         builder: (context) => AlertDialog(
//           title: Text(detail.notificacion.titulo),
//           content: SingleChildScrollView(
//             child: SelectableText(detail.notificacion.mensaje),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cerrar'),
//             ),
//           ],
//         ),
//       );
//     } catch (error) {
//       // Conserva la apertura pendiente para reintentar.
//       debugPrint('[notificaciones] No se pudo abrir: $error');
//     } finally {
//       _opening = false;

//       // Si hubo otro toque durante la apertura, procesarlo.
//       if (mounted && _pending != null && !identical(_pending, request)) {
//         _scheduleOpen();
//       }
//     }
//   }

//   // ==========================================================
//   // CONSULTA AUTORIZADA EN EL BACKEND
//   // ==========================================================

//   Future<GetNotificacionByIdDataModel?> _fetchDetail(int id) async {
//     final result = await widget.useCases.getNotificacionById.run(id: id);

//     if (result is Success<ApiResponse<GetNotificacionByIdDataModel>>) {
//       return result.data.data;
//     }

//     if (result is ErrorData<ApiResponse<GetNotificacionByIdDataModel>>) {
//       // No mostrar una notificación ajena o inexistente.
//       if (result.statusCode == 403 || result.statusCode == 404) {
//         return null;
//       }

//       throw StateError(result.message);
//     }

//     throw StateError('El servidor no devolvió una respuesta válida.');
//   }

//   int? _parseId(Object? value) {
//     final id = int.tryParse(value?.toString() ?? '');

//     return id != null && id > 0 ? id : null;
//   }

//   // ==========================================================
//   // CAMBIOS DE SESIÓN Y CICLO DE VIDA
//   // ==========================================================

//   void _sessionChanged(SessionState state) {
//     if (state.status == SessionStatus.loggingOut ||
//         state.status == SessionStatus.unauthenticated) {
//       _pending = null;
//       _shown.clear();
//       _opened.clear();

//       if (_lastUserId != null) {
//         unawaited(
//           _local.cancelAll().catchError((Object error, StackTrace stackTrace) {
//             debugPrint('[notificaciones] No se pudieron limpiar los avisos.');
//           }),
//         );
//       }

//       _lastUserId = null;
//       return;
//     }

//     if (state.isAuthenticated) {
//       final userId = state.session!.usuario.idUsuario.toString();

//       if (_lastUserId != null && _lastUserId != userId) {
//         _pending = null;
//         _shown.clear();
//         _opened.clear();
//       }

//       _lastUserId = userId;
//       _scheduleOpen();
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _scheduleOpen();
//     }
//   }

//   @override
//   void dispose() {
//     _foregroundSubscription?.cancel();
//     _openedSubscription?.cancel();
//     _localTapSubscription?.cancel();

//     _retryTimer?.cancel();

//     appRouter.routerDelegate.removeListener(_scheduleOpen);
//     WidgetsBinding.instance.removeObserver(this);

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<SessionBloc, SessionState>(
//       listener: (_, state) => _sessionChanged(state),
//       child: widget.child,
//     );
//   }
// }

// class _NotificationOpenRequest {
//   final int id;
//   final String? ownerId;

//   const _NotificationOpenRequest({required this.id, this.ownerId});
// }
