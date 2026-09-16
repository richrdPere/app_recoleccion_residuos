import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Estas pantallas administran sus resultados y errores.
const authFlowRoutes = <String>{'/splash', '/loading', '/logout'};

// Rutas públicas implementadas.
const publicRoutes = <String>{'/login'};

String? authRedirect(BuildContext context, GoRouterState state) {
  final session = context.read<SessionBloc>().state;
  final location = state.uri.path;

  // *********************************************************
  // 1. RESPETAR LAS PANTALLAS DEL FLUJO DE AUTENTICACIÓN
  // *********************************************************
  //
  // Por ejemplo, Logout debe poder mostrar un fallo de limpieza
  // local aunque SessionBloc ya esté en unauthenticated.
  if (authFlowRoutes.contains(location)) {
    return null;
  }

  // *********************************************************
  // 2. EVALUAR EL ESTADO REAL DE LA SESIÓN
  // *********************************************************
  switch (session.status) {
    case SessionStatus.initial:
    case SessionStatus.restoring:
      return '/splash';

    case SessionStatus.saving:
      return '/loading';

    case SessionStatus.loggingOut:
      return '/logout';

    case SessionStatus.authenticated:
      if (location == '/login') {
        return '/home';
      }

      return null;

    case SessionStatus.unauthenticated:
      if (publicRoutes.contains(location)) {
        return null;
      }

      return '/login';
  }
}
