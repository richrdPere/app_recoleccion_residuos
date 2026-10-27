import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GeolocatorState {
  final Resource<bool> servicio;
  final Resource<PermisoUbicacion> permiso;

  final Resource<UbicacionEntity> ubicacionActual;
  final Resource<UbicacionEntity?> ultimaUbicacion;
  final Resource<UbicacionEntity> seguimiento;

  final Resource<bool> aperturaConfiguracionAplicacion;
  final Resource<bool> aperturaConfiguracionUbicacion;

  final bool observandoServicio;
  final bool siguiendoUbicacion;

  const GeolocatorState({
    required this.servicio,
    required this.permiso,
    required this.ubicacionActual,
    required this.ultimaUbicacion,
    required this.seguimiento,
    required this.aperturaConfiguracionAplicacion,
    required this.aperturaConfiguracionUbicacion,
    this.observandoServicio = false,
    this.siguiendoUbicacion = false,
  });

  factory GeolocatorState.initial() {
    return GeolocatorState(
      servicio: Initial<bool>(),
      permiso: Initial<PermisoUbicacion>(),
      ubicacionActual: Initial<UbicacionEntity>(),
      ultimaUbicacion: Initial<UbicacionEntity?>(),
      seguimiento: Initial<UbicacionEntity>(),
      aperturaConfiguracionAplicacion: Initial<bool>(),
      aperturaConfiguracionUbicacion: Initial<bool>(),
    );
  }

  GeolocatorState copyWith({
    Resource<bool>? servicio,
    Resource<PermisoUbicacion>? permiso,
    Resource<UbicacionEntity>? ubicacionActual,
    Resource<UbicacionEntity?>? ultimaUbicacion,
    Resource<UbicacionEntity>? seguimiento,
    Resource<bool>? aperturaConfiguracionAplicacion,
    Resource<bool>? aperturaConfiguracionUbicacion,
    bool? observandoServicio,
    bool? siguiendoUbicacion,
  }) {
    return GeolocatorState(
      servicio: servicio ?? this.servicio,
      permiso: permiso ?? this.permiso,
      ubicacionActual: ubicacionActual ?? this.ubicacionActual,
      ultimaUbicacion: ultimaUbicacion ?? this.ultimaUbicacion,
      seguimiento: seguimiento ?? this.seguimiento,
      aperturaConfiguracionAplicacion:
          aperturaConfiguracionAplicacion ??
          this.aperturaConfiguracionAplicacion,
      aperturaConfiguracionUbicacion:
          aperturaConfiguracionUbicacion ?? this.aperturaConfiguracionUbicacion,
      observandoServicio: observandoServicio ?? this.observandoServicio,
      siguiendoUbicacion: siguiendoUbicacion ?? this.siguiendoUbicacion,
    );
  }

  // *********************************************************
  // SERVICIO Y PERMISO
  // *********************************************************

  /// null significa que todavía no hay un resultado exitoso.
  bool? get servicioHabilitado {
    final recurso = servicio;

    return recurso is Success<bool> ? recurso.data : null;
  }

  PermisoUbicacion? get permisoActual {
    final recurso = permiso;

    return recurso is Success<PermisoUbicacion> ? recurso.data : null;
  }

  bool get tienePermiso {
    return permisoActual == PermisoUbicacion.duranteUso ||
        permisoActual == PermisoUbicacion.siempre;
  }

  // *********************************************************
  // UBICACIONES
  // *********************************************************

  UbicacionEntity? get posicionActual {
    final recurso = ubicacionActual;

    return recurso is Success<UbicacionEntity> ? recurso.data : null;
  }

  UbicacionEntity? get posicionAnterior {
    final recurso = ultimaUbicacion;

    return recurso is Success<UbicacionEntity?> ? recurso.data : null;
  }

  UbicacionEntity? get posicionSeguimiento {
    final recurso = seguimiento;

    return recurso is Success<UbicacionEntity> ? recurso.data : null;
  }

  bool get obteniendoUbicacion => ubicacionActual is Loading<UbicacionEntity>;

  bool get esperandoPrimeraPosicion =>
      siguiendoUbicacion && seguimiento is Loading<UbicacionEntity>;
}
