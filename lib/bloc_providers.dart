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
  // 6. PERFIL
  // *********************************************************
  BlocProvider<PerfilBloc>(
    create: (context) => PerfilBloc(locator<AuthUsesCases>()),
  ),

  // *********************************************************
  // 7. RECORRIDOS
  // *********************************************************
  BlocProvider<RecorridoBloc>(
    create: (context) => RecorridoBloc(locator<RecorridoUsecases>()),
  ),

  // *********************************************************
  // 8. REGISTER - CIUDADANO
  // *********************************************************
  BlocProvider<RegisterBloc>(
    create: (_) => RegisterBloc(locator<AuthUsesCases>()),
  ),

  // *********************************************************
  // 9. CUENTA - CIUDADANO
  // *********************************************************
  BlocProvider<CiudadanoCuentaBloc>(
    create: (_) => CiudadanoCuentaBloc(locator<CiudadanosUseCases>()),
  ),

  // *********************************************************
  // 10. INICIO - CIUDADANO
  // *********************************************************
  BlocProvider<CiudadanoInicioBloc>(
    create: (_) => CiudadanoInicioBloc(locator<DomiciliosUseCases>()),
  ),

  // *********************************************************
  // 11. DOMICILIOS - CIUDADANO
  // *********************************************************
  BlocProvider<CiudadanoDomiciliosBloc>(
    create: (_) => CiudadanoDomiciliosBloc(locator<DomiciliosUseCases>()),
  ),

  // *********************************************************
  // 12. MAPA BASE
  // *********************************************************
  BlocProvider<MapaBloc>(
    create: (_) =>
        MapaBloc(locator<MapaUsesCase>())..add(const MapaInicializado()),
  ),

  // *********************************************************
  // 13. DIRECTIONS
  // *********************************************************
  BlocProvider<DirectionsBloc>(
    create: (_) => DirectionsBloc(locator<DirectionsUseCases>()),
  ),

  // *********************************************************
  // 14. GEOLOCODING
  // *********************************************************
  BlocProvider<GeocodingBloc>(
    create: (_) => GeocodingBloc(locator<GeocodingUseCases>()),
  ),

  // *********************************************************
  // 15. GEOLOCATOR
  // *********************************************************
  BlocProvider<GeolocatorBloc>(
    create: (_) => GeolocatorBloc(locator<GeolocatorUseCases>()),
  ),

  // *********************************************************
  // 16. PROGRAMACIONES
  // *********************************************************
  BlocProvider<ProgramacionesBloc>(
    create: (_) => ProgramacionesBloc(locator<ProgramacionesUseCases>()),
  ),

  // *********************************************************
  // 17. TRACKING
  // *********************************************************
  BlocProvider<TrackingBloc>(
    create: (_) => TrackingBloc(locator<TrackingUseCases>()),
  ),

  // *********************************************************
  // 18. INCIDENCIAS
  // *********************************************************
    BlocProvider<IncidenciasBloc>(
    create: (_) => IncidenciasBloc(locator<IncidenciasUseCases>()),
  ),
];
