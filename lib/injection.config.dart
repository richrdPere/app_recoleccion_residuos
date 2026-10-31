// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:app_recoleccion_residuos/src/data/datasources/local/local.dart'
    as _i972;
import 'package:app_recoleccion_residuos/src/data/datasources/local/shared/shared_pref.dart'
    as _i454;
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart'
    as _i322;
import 'package:app_recoleccion_residuos/src/di/AppModule.dart' as _i746;
import 'package:app_recoleccion_residuos/src/domain/repositories.dart' as _i704;
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart' as _i1034;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
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
    gh.factory<_i322.CiudadanosService>(() => appmodule.ciudadanosService);
    gh.factory<_i322.DomiciliosService>(() => appmodule.domiciliosService);
    gh.factory<_i322.PrefNotificationService>(
      () => appmodule.prefNotificationService,
    );
    gh.factory<_i322.IncidenciasService>(() => appmodule.incidenciasService);
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
    gh.factory<_i704.CiudadanosRepository>(
      () => appmodule.ciudadanosRepository,
    );
    gh.factory<_i704.DomiciliosRepository>(
      () => appmodule.domiciliosRepository,
    );
    gh.factory<_i704.PrefNotificationRepository>(
      () => appmodule.prefNotificationRepository,
    );
    gh.factory<_i704.IncidenciasRepository>(
      () => appmodule.incidenciasRepository,
    );
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
    gh.factory<_i1034.CiudadanosUseCases>(() => appmodule.ciudadanosUsesCases);
    gh.factory<_i1034.DomiciliosUseCases>(() => appmodule.domiciliosUsesCases);
    gh.factory<_i1034.PrefNotificationUseCases>(
      () => appmodule.prefNotificationUsesCases,
    );
    gh.factory<_i1034.IncidenciasUseCases>(
      () => appmodule.incidenciasUsesCases,
    );
    gh.factory<_i1034.MapaUsesCase>(() => appmodule.mapaUsesCases);
    gh.factory<_i1034.DirectionsUseCases>(() => appmodule.directionsUsesCases);
    gh.factory<_i1034.GeocodingUseCases>(() => appmodule.geocodingUsesCases);
    gh.factory<_i1034.GeolocatorUseCases>(() => appmodule.geolocatorUsesCases);
    gh.lazySingleton<_i704.MapaRepository>(() => appmodule.mapaRepository);
    gh.lazySingleton<_i322.DirectionsService>(
      () => appmodule.directionsService,
    );
    gh.lazySingleton<_i322.GeocodingService>(() => appmodule.geocodingService);
    gh.lazySingleton<_i972.GeolocatorService>(
      () => appmodule.geolocatorService,
    );
    gh.lazySingleton<_i704.DirectionsRepository>(
      () => appmodule.directionsRepository,
    );
    gh.lazySingleton<_i704.GeocodingRepository>(
      () => appmodule.geocodingRepository,
    );
    gh.lazySingleton<_i704.GeolocatorRepository>(
      () => appmodule.geolocatorRepository,
    );
    gh.factory<String>(
      () => appmodule.mapBoxApiKey,
      instanceName: 'mapBoxApiKey',
    );
    gh.lazySingleton<_i519.Client>(
      () => appmodule.mapboxHttpClient,
      instanceName: 'mapboxHttpClient',
    );
    return this;
  }
}

class _$Appmodule extends _i746.Appmodule {}
