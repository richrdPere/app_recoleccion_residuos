import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Autenticación
import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';

// Main shell
import 'package:app_recoleccion_residuos/src/config/core/main_shell/main_shell.dart';
import 'package:app_recoleccion_residuos/src/config/core/main_shell/ciudadano_Shell.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

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
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (_, _) => const RegisterPage(),
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
          builder: (_, _) => const RecorridoPage(),
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

    // *******************************************************
    // CIUDADANOS - OPERACIONES
    // *******************************************************
    ShellRoute(
      builder: (context, state, child) {
        return CiudadanoShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/ciudadano/inicio',
          name: 'ciudadano-inicio',
          builder: (context, state) => const CiudadanoInicioPage(),
        ),
        GoRoute(
          path: '/ciudadano/mapa',
          name: 'ciudadano-mapa',
          builder: (context, state) =>
              const Center(child: Text('Mapa de recolección')),
        ),
        GoRoute(
          path: '/ciudadano/alertas',
          name: 'ciudadano-alertas',
          builder: (context, state) =>
              const Center(child: Text('Alertas ciudadanas')),
        ),
        GoRoute(
          path: '/ciudadano/perfil',
          name: 'ciudadano-perfil',
          builder: (context, state) => const CiudadanoCuentaPage(),
          routes: [
            GoRoute(
              path: 'editar/:idCiudadano',
              name: 'ciudadano-perfil-editar',
              builder: (context, state) {
                final id = int.tryParse(
                  state.pathParameters['idCiudadano'] ?? '',
                );

                if (id == null || id <= 0) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Editar perfil')),
                    body: const Center(
                      child: Text('El identificador del perfil no es válido.'),
                    ),
                  );
                }

                return CiudadanoPerfilEditPage(idCiudadano: id);
              },
            ),
            GoRoute(
              path: 'domicilios',
              name: 'ciudadano-domicilios',
              builder: (context, state) => const CiudadanoDomiciliosPage(),
            ),
          ],
        ),
      ],
    ),

    // *******************************************************
    // CON ACCESSO
    // *******************************************************

    // - Ciudadano
    GoRoute(
      path: '/ciudadano/acceso',
      name: 'ciudadano-acceso',
      builder: (context, state) => const CiudadanoAccesoPage(),
    ),

    // *******************************************************
    // SIN ACCESSO
    // *******************************************************
    GoRoute(
      path: '/sin-acceso',
      name: 'sin-acceso',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Acceso no disponible'),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_accounts_outlined, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Tu cuenta no tiene un rol habilitado '
                    'para utilizar esta aplicación.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      context.read<SessionBloc>().add(
                        const SessionLogoutRequested(),
                      );
                    },
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ],
);
