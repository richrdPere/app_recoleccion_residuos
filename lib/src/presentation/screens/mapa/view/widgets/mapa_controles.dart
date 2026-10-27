import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Widgets
import 'mapa_permisos_panel.dart';

class MapaControles extends StatelessWidget {
  final bool ubicacionPendiente;
  final UbicacionEntity? ubicacion;
  final DireccionGeograficaEntity? destino;

  final VoidCallback onSolicitarUbicacion;
  final VoidCallback onAbrirConfiguracionUbicacion;
  final VoidCallback onAbrirConfiguracionAplicacion;
  final VoidCallback onConsultarDireccion;
  final VoidCallback onCalcularRuta;

  const MapaControles({
    super.key,
    required this.ubicacionPendiente,
    required this.ubicacion,
    required this.destino,
    required this.onSolicitarUbicacion,
    required this.onAbrirConfiguracionUbicacion,
    required this.onAbrirConfiguracionAplicacion,
    required this.onConsultarDireccion,
    required this.onCalcularRuta,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MapaPermisosPanel(
              ubicacionPendiente: ubicacionPendiente,
              ubicacion: ubicacion,
              onSolicitarUbicacion: onSolicitarUbicacion,
              onAbrirConfiguracionUbicacion: onAbrirConfiguracionUbicacion,
              onAbrirConfiguracionAplicacion: onAbrirConfiguracionAplicacion,
            ),

            const Divider(height: 24),

            BlocBuilder<DirectionsBloc, DirectionsState>(
              builder: (context, state) {
                final ruta = state.ruta;
                final destinoActual = destino;

                final puedeCalcular =
                    !state.estaCalculando &&
                    !ubicacionPendiente &&
                    ubicacion != null &&
                    destinoActual != null;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destinoActual == null
                          ? 'Busca y selecciona un destino.'
                          : 'Destino: '
                                '${destinoActual.direccionFormateada}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (ruta != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${(ruta.distanciaMetros / 1000).toStringAsFixed(2)} km'
                        ' · '
                        '${(ruta.duracionSegundos / 60).toStringAsFixed(0)} min',
                      ),
                    ],

                    if (state.estaCalculando) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        BlocBuilder<GeocodingBloc, GeocodingState>(
                          buildWhen: (anterior, actual) =>
                              anterior.direccion != actual.direccion,
                          builder: (context, geocodingState) {
                            return OutlinedButton(
                              onPressed:
                                  ubicacion == null ||
                                      ubicacionPendiente ||
                                      geocodingState.estaObteniendoDireccion
                                  ? null
                                  : onConsultarDireccion,
                              child: Text(
                                geocodingState.estaObteniendoDireccion
                                    ? 'Consultando…'
                                    : 'Ver dirección',
                              ),
                            );
                          },
                        ),
                        FilledButton.icon(
                          onPressed: puedeCalcular ? onCalcularRuta : null,
                          icon: const Icon(Icons.alt_route),
                          label: const Text('Calcular camino'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
