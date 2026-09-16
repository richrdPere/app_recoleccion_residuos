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

  // =============================================================
  // 2. REPOSITORY
  // =============================================================

  // - Auth
  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

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
