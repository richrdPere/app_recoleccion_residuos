import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class AuthListener extends StatefulWidget {
  final Widget child;
  final GoRouter router;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const AuthListener({
    super.key,
    required this.child,
    required this.router,
    required this.scaffoldMessengerKey,
  });

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;

  bool _refreshScheduled = false;
  bool _appResumed = true;

  // Evita intentos muy frecuentes después de errores temporales.
  DateTime? _retryNotBefore;

  // *********************************************************
  // 1. INICIALIZACIÓN
  // *********************************************************
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _appResumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;

    _scheduleRouterRefresh();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _scheduleTokenRefresh(context.read<SessionBloc>().state);
    });
  }

  @override
  void didUpdateWidget(covariant AuthListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.router != widget.router) {
      _scheduleRouterRefresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // *********************************************************
  // 2. REGRESO A LA APLICACIÓN
  // *********************************************************
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    _appResumed = lifecycle == AppLifecycleState.resumed;

    if (!_appResumed) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      return;
    }

    if (!mounted) return;

    _scheduleTokenRefresh(context.read<SessionBloc>().state);
  }

  // *********************************************************
  // 3. REEVALUAR REDIRECT
  // *********************************************************
  void _scheduleRouterRefresh() {
    if (!mounted || _refreshScheduled) return;

    _refreshScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;

      if (!mounted) return;

      widget.router.refresh();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
  }

  // *********************************************************
  // 4. LEER FECHA DE EXPIRACIÓN
  // *********************************************************
  DateTime? _tokenExpiration(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) return null;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      if (payload is! Map) return null;

      final exp = payload['exp'];
      if (exp is! num) return null;

      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  // *********************************************************
  // 5. PROGRAMAR RENOVACIÓN
  // *********************************************************
  void _scheduleTokenRefresh(SessionState state) {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    if (!mounted || !_appResumed || !state.isAuthenticated) return;

    final session = state.session;
    if (session == null) return;

    final expiration = _tokenExpiration(session.accessToken);

    // La lectura local solo sirve para programar el refresh.
    // La validez del token la determina el backend.
    if (expiration == null) return;

    final now = DateTime.now().toUtc();

    var refreshAt = expiration.subtract(const Duration(seconds: 30));

    final retryAt = _retryNotBefore;
    if (retryAt != null && retryAt.isAfter(refreshAt)) {
      refreshAt = retryAt;
    }

    final difference = refreshAt.difference(now);
    final delay = difference.isNegative ? Duration.zero : difference;

    final scheduledToken = session.accessToken;

    _refreshTimer = Timer(delay, () {
      if (!mounted || !_appResumed) return;

      final bloc = context.read<SessionBloc>();
      final current = bloc.state;

      if (bloc.isClosed ||
          !current.isAuthenticated ||
          current.session?.accessToken != scheduledToken) {
        return;
      }

      // Si temporalmente falla, no volver a intentarlo
      // inmediatamente al recibir el estado de error.
      _retryNotBefore = DateTime.now().toUtc().add(const Duration(seconds: 30));

      bloc.add(const SessionRefreshRequested());
    });
  }

  // *********************************************************
  // 6. MOSTRAR ERRORES
  // *********************************************************
  void _showSessionError(String? message) {
    if (message == null || message.trim().isEmpty) return;

    final location = widget.router.routerDelegate.currentConfiguration.uri.path;

    if (authFlowRoutes.contains(location)) return;

    final messenger = widget.scaffoldMessengerKey.currentState;

    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // *********************************************************
  // 7. ESCUCHAR SESIÓN
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        // Solo reevaluar navegación si cambian estado o sesión.
        if (_lastStatus != state.status ||
            !identical(_lastSession, state.session)) {
          _scheduleRouterRefresh();
        }

        final token = state.session?.accessToken;

        if (!state.isAuthenticated || token != _lastAccessToken) {
          _retryNotBefore = null;
        }

        _lastStatus = state.status;
        _lastSession = state.session;
        _lastAccessToken = token;

        _scheduleTokenRefresh(state);

        if (state.errorMessage != null) {
          _showSessionError(state.errorMessage);
        }
      },
      child: widget.child,
    );
  }

  SessionStatus? _lastStatus;
  Object? _lastSession;
  String? _lastAccessToken;
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';
// import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// class AuthListener extends StatefulWidget {
//   final Widget child;
//   final GoRouter router;
//   final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

//   const AuthListener({
//     super.key,
//     required this.child,
//     required this.router,
//     required this.scaffoldMessengerKey,
//   });

//   @override
//   State<AuthListener> createState() => _AuthListenerState();
// }

// class _AuthListenerState extends State<AuthListener> {
//   bool _refreshScheduled = false;

//   // *********************************************************
//   // 1. REVISIÓN INICIAL
//   // *********************************************************
//   @override
//   void initState() {
//     super.initState();

//     // Cubre una restauración que terminó antes de montar
//     // el listener.
//     _scheduleRefresh();
//   }

//   @override
//   void didUpdateWidget(covariant AuthListener oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.router != widget.router) {
//       _scheduleRefresh();
//     }
//   }

//   // *********************************************************
//   // 2. REEVALUAR REDIRECT
//   // *********************************************************
//   void _scheduleRefresh() {
//     if (!mounted || _refreshScheduled) return;

//     _refreshScheduled = true;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _refreshScheduled = false;

//       if (!mounted) return;

//       widget.router.refresh();
//     });

//     WidgetsBinding.instance.ensureVisualUpdate();
//   }

//   // *********************************************************
//   // 3. MOSTRAR ERRORES
//   // *********************************************************
//   void _showSessionError(String? message) {
//     if (message == null || message.isEmpty) return;

//     final location = widget.router.routerDelegate.currentConfiguration.uri.path;

//     // Estas páginas muestran sus propios errores.
//     if (authFlowRoutes.contains(location)) return;

//     final messenger = widget.scaffoldMessengerKey.currentState;

//     messenger?.hideCurrentSnackBar();
//     messenger?.showSnackBar(
//       SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
//     );
//   }

//   // *********************************************************
//   // 4. ESCUCHAR SESIÓN
//   // *********************************************************
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<SessionBloc, SessionState>(
//           listenWhen: (previous, current) {
//             return previous.status != current.status ||
//                 previous.session != current.session;
//           },
//           listener: (_, _) {
//             _scheduleRefresh();
//           },
//         ),
//         BlocListener<SessionBloc, SessionState>(
//           listenWhen: (previous, current) {
//             return previous.errorMessage != current.errorMessage;
//           },
//           listener: (_, state) {
//             _showSessionError(state.errorMessage);
//           },
//         ),
//       ],
//       child: widget.child,
//     );
//   }
// }
