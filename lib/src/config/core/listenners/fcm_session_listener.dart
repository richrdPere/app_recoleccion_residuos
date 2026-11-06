import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/config/core/notifications/fcm_session_coordinator.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_state.dart';

class FcmSessionListener extends StatefulWidget {
  final Widget child;
  final FcmSessionCoordinator coordinator;

  const FcmSessionListener({
    super.key,
    required this.child,
    required this.coordinator,
  });

  @override
  State<FcmSessionListener> createState() => _FcmSessionListenerState();
}

class _FcmSessionListenerState extends State<FcmSessionListener>
    with WidgetsBindingObserver {
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _sync(context.read<SessionBloc>().state);
      }
    });

    // Reintenta si el token inicial o el backend fallaron.
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;

      final lifecycle = WidgetsBinding.instance.lifecycleState;

      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
        return;
      }

      final state = context.read<SessionBloc>().state;

      if (state.isAuthenticated) {
        _sync(state);
      }
    });
  }

  void _sync(SessionState state) {
    if (state.isAuthenticated) {
      unawaited(
        widget.coordinator.syncSession(
          state.session!.usuario.idUsuario.toString(),
        ),
      );
      return;
    }

    if (state.status == SessionStatus.unauthenticated) {
      unawaited(widget.coordinator.syncSession(null));
    }

    // loggingOut se coordina desde SessionBloc.
    // Los estados transitorios no desactivan el registro.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _sync(context.read<SessionBloc>().state);
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    // El coordinador vive durante toda la aplicación.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (_, state) => _sync(state),
      child: widget.child,
    );
  }
}
