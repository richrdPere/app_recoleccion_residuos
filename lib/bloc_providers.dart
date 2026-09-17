import 'package:app_recoleccion_residuos/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Use cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

List<BlocProvider> blocProviders = [
  // *********************************************************
  // 1. SESSION - SESIÓN GLOBAL
  // *********************************************************
  BlocProvider<SessionBloc>(
    lazy: false,
    create: (_) =>
        SessionBloc(locator<AuthUsesCases>())..add(const SessionStarted()),
  ),

  // *********************************************************
  // 2. LOGIN
  // *********************************************************
  BlocProvider<LoginBloc>(create: (_) => LoginBloc(locator<AuthUsesCases>())),

  // *********************************************************
  // 3. SPLASH
  // *********************************************************
  BlocProvider<SplashBloc>(
    create: (context) => SplashBloc(sessionBloc: context.read<SessionBloc>()),
  ),

  // *********************************************************
  // 4. LOADING
  // *********************************************************
  BlocProvider<LoadingBloc>(
    create: (context) => LoadingBloc(sessionBloc: context.read<SessionBloc>()),
  ),

  // *********************************************************
  // 5. LOGOUT
  // *********************************************************
  BlocProvider<LogoutBloc>(
    create: (context) => LogoutBloc(sessionBloc: context.read<SessionBloc>()),
  ),

  // *********************************************************
  // 5. PERFIL
  // *********************************************************
  BlocProvider<PerfilBloc>(
    create: (context) => PerfilBloc(locator<AuthUsesCases>()),
  ),
];
