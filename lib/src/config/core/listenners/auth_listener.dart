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

class _AuthListenerState extends State<AuthListener> {
  bool _refreshScheduled = false;

  // *********************************************************
  // 1. REVISIÓN INICIAL
  // *********************************************************
  @override
  void initState() {
    super.initState();

    // Cubre una restauración que terminó antes de montar
    // el listener.
    _scheduleRefresh();
  }

  @override
  void didUpdateWidget(covariant AuthListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.router != widget.router) {
      _scheduleRefresh();
    }
  }

  // *********************************************************
  // 2. REEVALUAR REDIRECT
  // *********************************************************
  void _scheduleRefresh() {
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
  // 3. MOSTRAR ERRORES
  // *********************************************************
  void _showSessionError(String? message) {
    if (message == null || message.isEmpty) return;

    final location = widget.router.routerDelegate.currentConfiguration.uri.path;

    // Estas páginas muestran sus propios errores.
    if (authFlowRoutes.contains(location)) return;

    final messenger = widget.scaffoldMessengerKey.currentState;

    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // *********************************************************
  // 4. ESCUCHAR SESIÓN
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) {
            return previous.status != current.status ||
                previous.session != current.session;
          },
          listener: (_, _) {
            _scheduleRefresh();
          },
        ),
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) {
            return previous.errorMessage != current.errorMessage;
          },
          listener: (_, state) {
            _showSessionError(state.errorMessage);
          },
        ),
      ],
      child: widget.child,
    );
  }
}
