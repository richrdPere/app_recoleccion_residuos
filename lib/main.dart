import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:app_recoleccion_residuos/injection.dart';
import 'package:app_recoleccion_residuos/bloc_providers.dart';

// Services
import 'package:app_recoleccion_residuos/src/data/datasources/local/services/local_notification_service.dart';

// Uses cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Config
import 'package:app_recoleccion_residuos/src/config/router/app_router.dart';
import 'package:app_recoleccion_residuos/src/config/theme/app_theme.dart';
import 'package:app_recoleccion_residuos/src/config/core/sync/operacion_offline_scope.dart';

// Listeners
import 'package:app_recoleccion_residuos/src/config/core/listenners/auth_listener.dart';
import 'package:app_recoleccion_residuos/src/config/core/notifications/fcm_session_coordinator.dart';
import 'package:app_recoleccion_residuos/src/config/core/listenners/fcm_session_listener.dart';
import 'package:app_recoleccion_residuos/src/config/core/listenners/notifications_listener.dart';
import 'package:app_recoleccion_residuos/src/config/core/listenners/socket_session_listener.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Aquí no se navega ni se accede a widgets.
}

// *********************************************************
// 1. CLAVE GLOBAL PARA MENSAJES
// *********************************************************
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// *********************************************************
// 2. INICIALIZACIÓN
// *********************************************************

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await configureDependencies();

  await LocalNotificationsService.instance.initialize();

  runApp(const MyApp());
}

// *********************************************************
// 3. APLICACIÓN
// *********************************************************
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final toastBuilder = FToastBuilder();

    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Sistema de recolección de residuos',

        // Router
        routerConfig: appRouter,

        // Tema
        theme: AppTheme(selectedColor: 0).getTheme(),

        // Mensajes globales
        scaffoldMessengerKey: rootScaffoldMessengerKey,

        // Toasts y coordinación de autenticación
        builder: (context, child) {
          return OperacionOfflineScope(
            child: toastBuilder(
              context,
              AuthListener(
                router: appRouter,
                scaffoldMessengerKey: rootScaffoldMessengerKey,

                child: FcmSessionListener(
                  coordinator: locator<FcmSessionCoordinator>(),

                  child: SocketSessionListener(
                    child: NotificationsListener(
                      useCases: locator<NotificacionesUseCases>(),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
