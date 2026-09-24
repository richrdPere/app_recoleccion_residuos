// Environment
import 'package:injectable/injectable.dart';
import 'package:app_recoleccion_residuos/src/data/datasources/local/shared/shared_pref.dart';
import 'package:app_recoleccion_residuos/src/config/constants/environment.dart'
    as url_backend;

// DATABASE - Local

// SERVICES - Remote
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Repository - DOMAIN
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Repository Impl - DATA
import 'package:app_recoleccion_residuos/src/data/repositories_impl.dart';

// Use Cases
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

@module
abstract class Appmodule {
  @Named('googleMapsApiKey')
  String get googleMapsApiKey => url_backend.Environment.googleMapsAPI;

  // @lazySingleton
  // SocketRepository socketRepository() => SocketRepositoryImpl();

  // // CONNECTIVITY
  // @lazySingleton
  // Connectivity connectivity() => Connectivity();

  // @lazySingleton
  // ConnectivityService connectivityService(Connectivity connectivity) {
  //   return ConnectivityServiceImpl(connectivity: connectivity);
  // }

  // // SYNC MANAGER
  // @lazySingleton
  // SyncManager syncManager(ConnectivityService connectivityService) {
  //   return SyncManager(connectivityService: connectivityService);
  // }

  // // SYNC BLOC
  // @factoryMethod
  // SyncBloc syncBloc(SyncManager syncManager) {
  //   return SyncBloc(syncManager: syncManager);
  // }

  // // FIREBASE MESSAGING
  // @lazySingleton
  // FirebaseMessagingService get firebaseMessagingService =>
  //     FirebaseMessagingService.instance;

  // // MEDIA
  // @injectable
  // ImagePicker get imagePicker => ImagePicker();

  // @injectable
  // AudioRecorder get audioRecorder => AudioRecorder();

  // SHAREF PREF
  @injectable
  SharefPref get sharedPref => SharefPref();

  // DATABASE LOCAL
  // @lazySingleton
  // AppDatabasePatrullaje get appDatabasePatrullaje => AppDatabasePatrullaje();

  // =============================================================
  // 1. SERVICES (DATA SOURCE REMOTO)
  // =============================================================
  @injectable // Auth
  AuthService get authService => AuthService();

  @injectable // Dispositivos
  DispositivosService get dispositivoService => DispositivosService();

  @injectable // Notificaciones
  NotificacionesService get notificacionesService => NotificacionesService();

  @injectable // Programaciones
  ProgramacionesService get programacionesService => ProgramacionesService();

  @injectable // Recoleccion
  RecoleccionService get recoleccionService => RecoleccionService();

  @injectable // Recorrido
  RecorridoService get recorridoService => RecorridoService();

  @injectable // Tracking
  TrackingService get trackingService => TrackingService();

  // =============================================================
  // 2. REPOSITORY
  // =============================================================

  // - Auth
  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

  // - Dispositivos
  @injectable
  DispositivoRepository get dispositivoRepository =>
      DispositivoRepositoryImpl(dispositivoService, authRepository);

  // - Notificaciones
  @injectable
  NotificacionesRepository get notificacionesRepository =>
      NotificacionesRepositoryImpl(notificacionesService, authRepository);

  // - Programaciones
  @injectable
  ProgramacionesRepository get programacionesRepository =>
      ProgramacionesRepositoryImpl(programacionesService, authRepository);

  // - Recoleccion
  @injectable
  RecoleccionRepository get recoleccionRepository =>
      RecoleccionRepositoryImpl(recoleccionService, authRepository);

  // - Recorrido
  @injectable
  RecorridoRepository get recorridoRepository =>
      RecorridoRepositoryImpl(recorridoService, authRepository);

  // - Tracking
  @injectable
  TrackingRepository get trackingRepository =>
      TrackingRepositoryImpl(trackingService, authRepository);

  // =============================================================
  // 3. USES CASES
  // =============================================================

  // - Auth
  @injectable
  AuthUsesCases get authUseCases => AuthUsesCases(
    clearUserSession: ClearUserSessionUC(authRepository),
    getRefreshToken: GetRefreshTokenUC(authRepository),
    getToken: GetTokenUC(authRepository),
    getUserSession: GetUserSessionUC(authRepository),
    login: LoginUC(authRepository),
    logoutSession: LogoutUC(authRepository),
    saveUserSession: SaveUserSessionUC(authRepository),
    getProfileMeUC: GetProfileMeUC(authRepository),
  );

  // - Dispositivos
  @injectable
  DispositivosUseCases get dispositivosUseCases => DispositivosUseCases(
    desactivarDispositivoPorToken: DesactivarDispositivoPorTokenUC(
      dispositivoRepository,
    ),
    desactivarDispositivo: DesactivarDispositivoUC(dispositivoRepository),
    getMisDispositivos: GetMisDispositivosUC(dispositivoRepository),
    registrarDispositivo: RegistrarDispositivoUC(dispositivoRepository),
  );

  // - Notificaciones
  @injectable
  NotificacionesUseCases get notificacionesUsesCases => NotificacionesUseCases(
    archivarNotificacion: ArchivarNotificacionUC(notificacionesRepository),
    getMisNotificaciones: GetMisNotificacionesUC(notificacionesRepository),
    getNotificacionById: GetNotificacionByIdUC(notificacionesRepository),
    getTotalNoLeidas: GetTotalNoLeidasUC(notificacionesRepository),
    marcarNotificacionLeida: MarcarNotificacionLeidaUC(
      notificacionesRepository,
    ),
    marcarTodasNotificacionesLeidas: MarcarTodasNotificacionesLeidasUC(
      notificacionesRepository,
    ),
  );

  // - Programaciones
  @injectable
  ProgramacionesUseCases get programacionesUsesCases => ProgramacionesUseCases(
    getMisAsignaciones: GetMisAsignacionesUC(programacionesRepository),
    getProgramacionDetalle: GetProgramacionDetalleUC(programacionesRepository),
    responderAsignacion: ResponderAsignacionUC(programacionesRepository),
  );

  // - Recoleccion
  @injectable
  RecoleccionUseCases get recoleccionUsesCases => RecoleccionUseCases(
    getPuntosRecorrido: GetPuntosRecorridoUC(recoleccionRepository),
    getRecoleccionById: GetRecoleccionByIdUC(recoleccionRepository),
    getRecorridoProgreso: GetRecorridoProgresoUC(recoleccionRepository),
    registrarEvidencia: RegistrarEvidenciaUC(recoleccionRepository),
    registrarRecoleccionLote: RegistrarRecoleccionLoteUC(recoleccionRepository),
    registrarRecoleccion: RegistrarRecoleccionUC(recoleccionRepository),
  );

  // - Recorrido
  @injectable
  RecorridoUsecases get recorridoUsesCases => RecorridoUsecases(
    finalizarRecorrido: FinalizarRecorridoUC(recorridoRepository),
    getMisRecorridos: GetMisRecorridosUC(recorridoRepository),
    getRecorridoActivo: GetRecorridoActivoUC(recorridoRepository),
    getRecorridoById: GetRecorridoByIdUC(recorridoRepository),
    iniciarRecorrido: IniciarRecorridoUC(recorridoRepository),
    pausarRecorrido: PausarRecorridoUC(recorridoRepository),
    reanudarRecorrido: ReanudarRecorridoUC(recorridoRepository),
  );

  // - Tracking
  @injectable
  TrackingUseCases get trackingUsesCases => TrackingUseCases(
    registrarUbicacionLote: RegistrarUbicacionLoteUC(trackingRepository),
    registrarUbicacion: RegistrarUbicacionUC(trackingRepository),
  );

  // =============================================================
  // 4. SOCKETS
  // =============================================================
  // - Socket
  // @lazySingleton
  // SocketUseCases socketUseCases(SocketRepository socketRepository) =>
  //     SocketUseCases(
  //       connectSocket: ConnectSocketUseCase(socketRepository),
  //       disconnetSocket: DisconnetSocketUseCase(socketRepository),
  //       getSocket: GetSocketUseCase(socketRepository),
  //     );

  // @lazySingleton
  // SocketBloc socketBloc(
  //   SocketUseCases socketUseCases,
  //   AuthUsesCases authUsesCases,
  // ) => SocketBloc(socketUseCases, authUsesCases);
}
