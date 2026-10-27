import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class MapaBuscador extends StatelessWidget {
  final TextEditingController controller;
  final bool mostrarResultados;
  final VoidCallback onBuscar;
  final ValueChanged<DireccionGeograficaEntity> onSeleccionarDestino;

  const MapaBuscador({
    super.key,
    required this.controller,
    required this.mostrarResultados,
    required this.onBuscar,
    required this.onSeleccionarDestino,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onBuscar(),
                    decoration: const InputDecoration(
                      hintText: 'Buscar destino',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onBuscar,
                  tooltip: 'Buscar',
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            if (mostrarResultados)
              BlocBuilder<GeocodingBloc, GeocodingState>(
                buildWhen: (anterior, actual) =>
                    anterior.busqueda != actual.busqueda,
                builder: (context, state) {
                  if (state.estaBuscando) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final error = state.errorBusqueda;

                  if (error != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (state.busquedaSinResultados) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('No se encontraron coincidencias.'),
                    );
                  }

                  final resultados = state.resultadosBusqueda;

                  if (resultados.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: resultados.length,
                      itemBuilder: (context, index) {
                        final resultado = resultados[index];

                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(
                            resultado.direccionFormateada,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => onSeleccionarDestino(resultado),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
