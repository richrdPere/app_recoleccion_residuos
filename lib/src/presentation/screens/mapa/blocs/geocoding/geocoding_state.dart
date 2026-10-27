import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class GeocodingState {
  /// Resultados de buscar una dirección por texto.
  final Resource<List<DireccionGeograficaEntity>> busqueda;

  /// Resultados de consultar una dirección por coordenadas.
  final Resource<List<DireccionGeograficaEntity>> direccion;

  const GeocodingState({required this.busqueda, required this.direccion});

  factory GeocodingState.initial() {
    return GeocodingState(
      busqueda: Initial<List<DireccionGeograficaEntity>>(),
      direccion: Initial<List<DireccionGeograficaEntity>>(),
    );
  }

  GeocodingState copyWith({
    Resource<List<DireccionGeograficaEntity>>? busqueda,
    Resource<List<DireccionGeograficaEntity>>? direccion,
  }) {
    return GeocodingState(
      busqueda: busqueda ?? this.busqueda,
      direccion: direccion ?? this.direccion,
    );
  }

  // *********************************************************
  // BÚSQUEDA POR TEXTO
  // *********************************************************

  bool get estaBuscando => busqueda is Loading<List<DireccionGeograficaEntity>>;

  bool get busquedaExitosa =>
      busqueda is Success<List<DireccionGeograficaEntity>>;

  List<DireccionGeograficaEntity> get resultadosBusqueda {
    final recurso = busqueda;

    if (recurso is Success<List<DireccionGeograficaEntity>>) {
      return recurso.data;
    }

    return const [];
  }

  bool get busquedaSinResultados =>
      busquedaExitosa && resultadosBusqueda.isEmpty;

  String? get errorBusqueda {
    final recurso = busqueda;

    if (recurso is ErrorData<List<DireccionGeograficaEntity>>) {
      return recurso.fullMessage;
    }

    return null;
  }

  // *********************************************************
  // CONSULTA POR COORDENADAS
  // *********************************************************

  bool get estaObteniendoDireccion =>
      direccion is Loading<List<DireccionGeograficaEntity>>;

  bool get consultaDireccionExitosa =>
      direccion is Success<List<DireccionGeograficaEntity>>;

  List<DireccionGeograficaEntity> get resultadosDireccion {
    final recurso = direccion;

    if (recurso is Success<List<DireccionGeograficaEntity>>) {
      return recurso.data;
    }

    return const [];
  }

  bool get direccionSinResultados =>
      consultaDireccionExitosa && resultadosDireccion.isEmpty;

  String? get errorDireccion {
    final recurso = direccion;

    if (recurso is ErrorData<List<DireccionGeograficaEntity>>) {
      return recurso.fullMessage;
    }

    return null;
  }
}
