import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class DirectionsState {
  final Resource<RutaCalculadaEntity> resultado;

  const DirectionsState({required this.resultado});

  factory DirectionsState.initial() {
    return DirectionsState(resultado: Initial<RutaCalculadaEntity>());
  }

  // *********************************************************
  // ESTADOS
  // *********************************************************

  bool get esInicial => resultado is Initial<RutaCalculadaEntity>;

  bool get estaCalculando => resultado is Loading<RutaCalculadaEntity>;

  bool get tieneRuta => resultado is Success<RutaCalculadaEntity>;

  bool get tieneError => resultado is ErrorData<RutaCalculadaEntity>;

  // *********************************************************
  // RUTA CALCULADA
  // *********************************************************

  RutaCalculadaEntity? get ruta {
    final recurso = resultado;

    if (recurso is Success<RutaCalculadaEntity>) {
      return recurso.data;
    }

    return null;
  }

  // *********************************************************
  // ERROR
  // *********************************************************

  String? get mensajeError {
    final recurso = resultado;

    if (recurso is ErrorData<RutaCalculadaEntity>) {
      return recurso.fullMessage;
    }

    return null;
  }
}
