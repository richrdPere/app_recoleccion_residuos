// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class MapaDirectionsController {
  final DirectionsBloc directionsBloc;

  final void Function(String mensaje) onMensaje;
  final void Function(RutaCalculadaEntity? ruta) onRutaActualizada;

  MapaDirectionsController({
    required this.directionsBloc,
    required this.onMensaje,
    required this.onRutaActualizada,
  });

  // *********************************************************
  // 1. CALCULAR RUTA
  // *********************************************************

  void calcularRuta({
    required UbicacionEntity? ubicacion,
    required DireccionGeograficaEntity? destino,
  }) {
    if (ubicacion == null || destino == null) {
      onMensaje('Obtén tu ubicación y selecciona un destino.');
      return;
    }

    directionsBloc.add(
      CalcularRutaDirections(
        origen: ubicacion.coordenada,
        destino: destino.coordenada,
        incluirInstrucciones: true,
      ),
    );
  }

  // *********************************************************
  // 2. LIMPIAR RUTA
  // *********************************************************

  void limpiarRuta() {
    // Limpia el dibujo inmediatamente.
    onRutaActualizada(null);

    // Limpia el estado e invalida el cálculo anterior en el BLoC.
    directionsBloc.add(const LimpiarRutaDirections());
  }

  // *********************************************************
  // 3. PROCESAR ESTADO
  // *********************************************************

  void procesarEstado(DirectionsState state) {
    onRutaActualizada(state.ruta);

    final error = state.mensajeError;

    if (error != null) {
      onMensaje(error);
    }
  }
}
