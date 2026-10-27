import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Widgets
import 'mapa_base.dart';

class MapaBaseConBloc extends StatelessWidget {
  final void Function(MapboxMap mapboxMap)? onMapCreated;
  final VoidCallback? onStyleLoaded;

  const MapaBaseConBloc({super.key, this.onMapCreated, this.onStyleLoaded});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapaBloc, MapaState>(
      builder: (context, state) {
        if (state is MapaConfiguracionDisponible) {
          return MapaBase(
            configuracion: state.configuracion,
            onMapCreated: onMapCreated,
            onStyleLoaded: onStyleLoaded,
          );
        }

        if (state is MapaConfiguracionError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined, size: 48),
                  const SizedBox(height: 12),
                  Text(state.mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<MapaBloc>().add(const MapaInicializado());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
