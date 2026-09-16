import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Autenticación
import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';

// Main shell
import 'package:app_recoleccion_residuos/src/config/core/main_shell/main_shell.dart';

// Screens
import 'package:app_recoleccion_residuos/src/presentation/screens/screens.dart';

// *********************************************************
// NAVEGADOR PRINCIPAL
// *********************************************************
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// *********************************************************
// ROUTER
// *********************************************************
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  redirect: authRedirect,
  routes: [
    // *******************************************************
    // AUTENTICACIÓN
    // *******************************************************
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, _) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, _) => const LoginPage(),
    ),
    GoRoute(
      path: '/loading',
      name: 'loading',
      builder: (_, _) => const LoadingPage(),
    ),
    GoRoute(
      path: '/logout',
      name: 'logout',
      builder: (_, _) => const LogoutPage(),
    ),

    // *******************************************************
    // OPERACIONES
    // *******************************************************
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, _) => const HomePage(),
        ),
        GoRoute(
          path: '/mi-recorrido',
          name: 'mi_recorrido',
          builder: (_, _) => const MiRecorridoPage(),
        ),
        GoRoute(
          path: '/historial',
          name: 'historial',
          builder: (_, _) => const HistorialPage(),
        ),
        GoRoute(
          path: '/perfil',
          name: 'perfil',
          builder: (_, _) => const PerfilPage(),
        ),
      ],
    ),
  ],
);
