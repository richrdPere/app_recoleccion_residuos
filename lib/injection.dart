import 'package:app_recoleccion_residuos/injection.config.dart';
import 'package:app_recoleccion_residuos/src/config/core/notifications/fcm_session_coordinator.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final locator = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  locator.init();

  if (!locator.isRegistered<FcmSessionCoordinator>()) {
    locator.registerLazySingleton<FcmSessionCoordinator>(
      () => FcmSessionCoordinator(locator<DispositivosUseCases>()),
    );
  }
}

// @InjectableInit()
// Future<void> configureDependencies() async => locator.init();
