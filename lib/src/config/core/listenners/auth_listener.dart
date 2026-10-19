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

  StreamSubscription<CiudadanoCuentaState>? _ciudadanoCuentaSubscription;

  late final CiudadanoCuentaBloc _ciudadanoCuentaBloc;

  bool _refreshScheduled = false;
  bool _appResumed = true;

  DateTime? _retryNotBefore;

  SessionStatus? _lastStatus;
  Object? _lastSession;
  String? _lastAccessToken;

  String? _cuentaUsuarioId;

  // *********************************************************
  // 1. INICIALIZACIÓN
  // *********************************************************

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    final lifecycle = WidgetsBinding.instance.lifecycleState;

    _appResumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;

    final sessionState = context.read<SessionBloc>().state;

    _lastStatus = sessionState.status;
    _lastSession = sessionState.session;
    _lastAccessToken = sessionState.session?.accessToken;

    _cuentaUsuarioId = _getAuthenticatedUserId(sessionState);

    _ciudadanoCuentaBloc = context.read<CiudadanoCuentaBloc>();

    // Escuchar antes de solicitar el reset.
    _ciudadanoCuentaSubscription = _ciudadanoCuentaBloc.stream.listen((_) {
      if (!mounted) return;

      // authRedirect volverá a evaluar si el perfil
      // corresponde al usuario autenticado.
      _scheduleRouterRefresh();
    });

    // Evitar conservar datos de una ejecución anterior del árbol.
    _resetCiudadanoCuenta();

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
    _ciudadanoCuentaSubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    // Los BlocProvider son responsables de cerrar los BLoC.
    super.dispose();
  }

  // *********************************************************
  // 2. IDENTIFICAR AL USUARIO AUTENTICADO
  // *********************************************************

  String? _getAuthenticatedUserId(SessionState state) {
    if (!state.isAuthenticated) return null;

    final session = state.session;

    if (session == null) return null;

    return session.usuario.idUsuario.toString();
  }

  // *********************************************************
  // 3. LIMPIAR CUENTA CIUDADANA
  // *********************************************************

  void _resetCiudadanoCuenta() {
    if (!_ciudadanoCuentaBloc.isClosed) {
      _ciudadanoCuentaBloc.add(const CiudadanoCuentaReset());
    }

    final inicioBloc = context.read<CiudadanoInicioBloc>();

    if (!inicioBloc.isClosed) {
      inicioBloc.add(const CiudadanoInicioReset());
    }

    final domiciliosBloc = context.read<CiudadanoDomiciliosBloc>();

    if (!domiciliosBloc.isClosed) {
      domiciliosBloc.add(const CiudadanoDomiciliosReset());
    }
  }

  // *********************************************************
  // 4. SINCRONIZAR CUENTA CON LA SESIÓN
  // *********************************************************

  void _syncCiudadanoCuenta(SessionState state) {
    final usuarioId = _getAuthenticatedUserId(state);

    // Si solo cambian los tokens del mismo usuario,
    // conservar el perfil ciudadano.
    if (_cuentaUsuarioId == usuarioId) {
      return;
    }

    _cuentaUsuarioId = usuarioId;

    // Limpiar al cerrar sesión o cambiar de usuario.
    _resetCiudadanoCuenta();
  }

  // *********************************************************
  // 5. REGRESO A LA APLICACIÓN
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
  // 6. REEVALUAR REDIRECT
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
  // 7. LEER FECHA DE EXPIRACIÓN
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
  // 8. PROGRAMAR RENOVACIÓN
  // *********************************************************

  void _scheduleTokenRefresh(SessionState state) {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    if (!mounted || !_appResumed || !state.isAuthenticated) {
      return;
    }

    final session = state.session;

    if (session == null) return;

    final expiration = _tokenExpiration(session.accessToken);

    // Esta lectura únicamente programa el refresh.
    // El backend determina la validez del token.
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

      // Separar los reintentos ante errores temporales.
      _retryNotBefore = DateTime.now().toUtc().add(const Duration(seconds: 30));

      bloc.add(const SessionRefreshRequested());
    });
  }

  // *********************************************************
  // 9. MOSTRAR ERRORES DE SESIÓN
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
  // 10. ESCUCHAR SESIÓN
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        // Sincronizar y limpiar el perfil cuando corresponda.
        _syncCiudadanoCuenta(state);

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
}
