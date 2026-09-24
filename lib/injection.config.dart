// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:app_recoleccion_residuos/src/data/datasources/local/shared/shared_pref.dart'
    as _i454;
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart'
    as _i322;
import 'package:app_recoleccion_residuos/src/di/AppModule.dart' as _i746;
import 'package:app_recoleccion_residuos/src/domain/repositories.dart' as _i704;
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart' as _i1034;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appmodule = _$Appmodule();
    gh.factory<_i454.SharefPref>(() => appmodule.sharedPref);
    gh.factory<_i322.AuthService>(() => appmodule.authService);
    gh.factory<_i322.DispositivosService>(() => appmodule.dispositivoService);
    gh.factory<_i322.NotificacionesService>(
      () => appmodule.notificacionesService,
    );
    gh.factory<_i322.ProgramacionesService>(
      () => appmodule.programacionesService,
    );
    gh.factory<_i322.RecoleccionService>(() => appmodule.recoleccionService);
    gh.factory<_i322.RecorridoService>(() => appmodule.recorridoService);
    gh.factory<_i322.TrackingService>(() => appmodule.trackingService);
    gh.factory<_i704.AuthRepository>(() => appmodule.authRepository);
    gh.factory<_i704.DispositivoRepository>(
      () => appmodule.dispositivoRepository,
    );
    gh.factory<_i704.NotificacionesRepository>(
      () => appmodule.notificacionesRepository,
    );
    gh.factory<_i704.ProgramacionesRepository>(
      () => appmodule.programacionesRepository,
    );
    gh.factory<_i704.RecoleccionRepository>(
      () => appmodule.recoleccionRepository,
    );
    gh.factory<_i704.RecorridoRepository>(() => appmodule.recorridoRepository);
    gh.factory<_i704.TrackingRepository>(() => appmodule.trackingRepository);
    gh.factory<_i1034.AuthUsesCases>(() => appmodule.authUseCases);
    gh.factory<_i1034.DispositivosUseCases>(
      () => appmodule.dispositivosUseCases,
    );
    gh.factory<_i1034.NotificacionesUseCases>(
      () => appmodule.notificacionesUsesCases,
    );
    gh.factory<_i1034.ProgramacionesUseCases>(
      () => appmodule.programacionesUsesCases,
    );
    gh.factory<_i1034.RecoleccionUseCases>(
      () => appmodule.recoleccionUsesCases,
    );
    gh.factory<_i1034.RecorridoUsecases>(() => appmodule.recorridoUsesCases);
    gh.factory<_i1034.TrackingUseCases>(() => appmodule.trackingUsesCases);
    gh.factory<String>(
      () => appmodule.googleMapsApiKey,
      instanceName: 'googleMapsApiKey',
    );
    return this;
  }
}

class _$Appmodule extends _i746.Appmodule {}
