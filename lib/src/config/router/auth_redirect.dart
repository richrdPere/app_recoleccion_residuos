import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// *********************************************************
// RUTAS DEL FLUJO DE AUTENTICACIÓN
// *********************************************************

const authFlowRoutes = <String>{'/splash', '/loading', '/logout'};

// *********************************************************
// RUTAS PÚBLICAS IMPLEMENTADAS
// *********************************************************

const publicRoutes = <String>{'/login', '/register'};

// *********************************************************
// RUTAS DEL ÁREA OPERATIVA
// *********************************************************

const operationalRoutes = <String>{
  '/home',
  '/mi-recorrido',
  '/historial',
  '/perfil',
};

// *********************************************************
// ROLES CON ACCESO AL SHELL OPERATIVO
// *********************************************************

const operationalRoles = <String>{'CONDUCTOR', 'RECOLECTOR'};

// *********************************************************
// 1. EXTRAER TODOS LOS ROLES
// *********************************************************

Set<String> getSessionRoles(SessionState session) {
  final roles = session.session?.usuario.roles;

  if (roles == null) {
    return <String>{};
  }

  return roles.map((rol) => rol.nombre.trim().toUpperCase()).toSet();
}

// *********************************************************
// 2. DETERMINAR PANTALLA INICIAL
// *********************************************************

String getSessionHomeRoute(SessionState session) {
  final roles = getSessionRoles(session);

  final hasOperationalRole = roles.any(operationalRoles.contains);

  // Prioridad de inicio para cuentas con varios roles.
  if (hasOperationalRole) {
    return '/home';
  }

  // if (roles.contains('CIUDADANO')) {
  //   return '/ciudadano/inicio';
  // }
  if (roles.contains('CIUDADANO')) {
    return '/ciudadano/acceso';
  }

  return '/sin-acceso';
}

// *********************************************************
// 3. COMPROBAR RUTA Y SUBRUTAS
// *********************************************************

bool _matchesRoute(String location, String route) {
  return location == route || location.startsWith('$route/');
}

// *********************************************************
// 4. REDIRECCIÓN
// *********************************************************

String? authRedirect(BuildContext context, GoRouterState state) {
  final session = context.read<SessionBloc>().state;
  final location = state.uri.path;

  // Estas pantallas administran sus resultados y errores.
  if (authFlowRoutes.contains(location)) {
    return null;
  }

  switch (session.status) {
    case SessionStatus.initial:
    case SessionStatus.restoring:
      return '/splash';

    case SessionStatus.saving:
      return '/loading';

    case SessionStatus.loggingOut:
      return '/logout';

    case SessionStatus.unauthenticated:
      if (publicRoutes.contains(location)) {
        return null;
      }

      return '/login';

    case SessionStatus.authenticated:
      final roles = getSessionRoles(session);

      final isCiudadano = roles.contains('CIUDADANO');

      final isOperativo = roles.any(operationalRoles.contains);

      final homeRoute = getSessionHomeRoute(session);

      // Sin roles habilitados para la app.
      if (!isCiudadano && !isOperativo) {
        return location == '/sin-acceso' ? null : '/sin-acceso';
      }

      // Pantallas que no corresponden a una sesión autenticada.
      if (publicRoutes.contains(location) ||
          location == '/sin-acceso' ||
          location == '/') {
        return homeRoute;
      }

      // *******************************************************
      // ÁREA CIUDADANA
      // *******************************************************

      if (_matchesRoute(location, '/ciudadano')) {
        if (!isCiudadano) {
          return homeRoute;
        }

        // Permitir siempre la pantalla que consulta/crea el perfil.
        // Así evitamos redirigirla hacia sí misma.
        if (location == '/ciudadano/acceso') {
          return null;
        }

        final cuenta = context.read<CiudadanoCuentaBloc>().state;

        final idUsuarioSesion = session.session?.usuario.idUsuario;

        // No basta con tener un perfil cargado:
        // debe pertenecer al usuario actualmente autenticado.
        final perfilVerificado =
            cuenta.perfil != null &&
            idUsuarioSesion != null &&
            cuenta.perfil!.idUsuario.toString() == idUsuarioSesion.toString();

        if (!perfilVerificado) {
          return '/ciudadano/acceso';
        }

        return null;
      }

      // *******************************************************
      // ÁREA OPERATIVA
      // *******************************************************

      final isOperationalRoute = operationalRoutes.any(
        (route) => _matchesRoute(location, route),
      );

      if (isOperationalRoute) {
        return isOperativo ? null : homeRoute;
      }

      return null;
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// // Estas pantallas administran sus resultados y errores.
// const authFlowRoutes = <String>{'/splash', '/loading', '/logout'};

// // Rutas públicas implementadas.
// const publicRoutes = <String>{'/login', '/register'};

// String? authRedirect(BuildContext context, GoRouterState state) {
//   final session = context.read<SessionBloc>().state;
//   final location = state.uri.path;

//   // *********************************************************
//   // 1. RESPETAR LAS PANTALLAS DEL FLUJO DE AUTENTICACIÓN
//   // *********************************************************
//   //
//   // Por ejemplo, Logout debe poder mostrar un fallo de limpieza
//   // local aunque SessionBloc ya esté en unauthenticated.
//   if (authFlowRoutes.contains(location)) {
//     return null;
//   }

//   // *********************************************************
//   // 2. EVALUAR EL ESTADO REAL DE LA SESIÓN
//   // *********************************************************
//   switch (session.status) {
//     case SessionStatus.initial:
//     case SessionStatus.restoring:
//       return '/splash';

//     case SessionStatus.saving:
//       return '/loading';

//     case SessionStatus.loggingOut:
//       return '/logout';

//     case SessionStatus.authenticated:
//       if (publicRoutes.contains(location)) {
//         return '/home';
//       }

//       return null;

//     case SessionStatus.unauthenticated:
//       if (publicRoutes.contains(location)) {
//         return null;
//       }

//       return '/login';
//   }
// }
