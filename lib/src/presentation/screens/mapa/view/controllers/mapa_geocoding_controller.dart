// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class MapaGeocodingController {
  final GeocodingBloc geocodingBloc;

  final void Function(String mensaje) onMensaje;
  final void Function(bool mostrar) onMostrarResultados;
  final void Function(DireccionGeograficaEntity destino) onDestinoSeleccionado;

  MapaGeocodingController({
    required this.geocodingBloc,
    required this.onMensaje,
    required this.onMostrarResultados,
    required this.onDestinoSeleccionado,
  });

  // *********************************************************
  // 1. BUSCAR DESTINO
  // *********************************************************

  void buscarDestino({required String texto, CoordenadaEntity? proximidad}) {
    final consulta = texto.trim();

    if (consulta.isEmpty) {
      onMostrarResultados(false);
      onMensaje('Escribe una dirección.');
      return;
    }

    onMostrarResultados(true);

    geocodingBloc.add(
      BuscarDireccionGeocoding(
        texto: consulta,
        proximidad:
            proximidad ??
            const CoordenadaEntity(latitud: -13.3214, longitud: -71.9556),
      ),
    );
  }

  // *********************************************************
  // 2. SELECCIONAR DESTINO
  // *********************************************************

  void seleccionarDestino(DireccionGeograficaEntity destino) {
    onMostrarResultados(false);
    onDestinoSeleccionado(destino);
  }

  // *********************************************************
  // 3. CONSULTAR DIRECCIÓN DE MI UBICACIÓN
  // *********************************************************

  void consultarMiDireccion(UbicacionEntity? ubicacion) {
    if (ubicacion == null) {
      onMensaje('Primero obtén tu ubicación.');
      return;
    }

    geocodingBloc.add(
      ObtenerDireccionGeocoding(coordenada: ubicacion.coordenada),
    );
  }

  // *********************************************************
  // 4. PROCESAR RESULTADO DE GEOCODIFICACIÓN INVERSA
  // *********************************************************

  void procesarEstado(GeocodingState state) {
    final error = state.errorDireccion;

    if (error != null) {
      onMensaje(error);
      return;
    }

    if (!state.consultaDireccionExitosa) return;

    final resultados = state.resultadosDireccion;

    onMensaje(
      resultados.isEmpty
          ? 'No se encontró una dirección para este punto.'
          : resultados.first.direccionFormateada,
    );
  }
}
