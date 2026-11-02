import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class MapaResultadosBusqueda extends StatelessWidget {
  final ValueChanged<DireccionGeograficaEntity> onSeleccionarDestino;

  final VoidCallback onReintentar;

  const MapaResultadosBusqueda({
    super.key,
    required this.onSeleccionarDestino,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeocodingBloc, GeocodingState>(
      buildWhen: (anterior, actual) => anterior.busqueda != actual.busqueda,
      builder: (context, state) {
        // No mostrar un panel antes de iniciar una búsqueda.
        if (!state.estaBuscando &&
            !state.busquedaExitosa &&
            state.errorBusqueda == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        final resultados = state.resultadosBusqueda;

        return Material(
          color: colors.surface,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // *******************************************
              // ENCABEZADO
              // *******************************************
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 21,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.estaBuscando
                            ? 'Buscando direcciones…'
                            : 'Selecciona una dirección',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (state.busquedaExitosa)
                      Text(
                        '${resultados.length}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // *******************************************
              // CARGA
              // *******************************************
              if (state.estaBuscando)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: SizedBox.square(
                    dimension: 25,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              // *******************************************
              // ERROR
              // *******************************************
              else if (state.errorBusqueda != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        state.errorBusqueda!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onReintentar,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              // *******************************************
              // SIN RESULTADOS
              // *******************************************
              else if (resultados.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        color: colors.onSurfaceVariant,
                        size: 30,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No encontramos direcciones.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prueba con el nombre de una calle, '
                        'un lugar o una dirección más completa.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              // *******************************************
              // DIRECCIONES ENCONTRADAS
              // *******************************************
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: resultados.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, index) {
                      final resultado = resultados[index];

                      final nombre = resultado.nombre?.trim();

                      final direccion = resultado.direccionFormateada;

                      final titulo = nombre != null && nombre.isNotEmpty
                          ? nombre
                          : direccion;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Icon(
                          Icons.place_outlined,
                          color: colors.primary,
                        ),
                        title: Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: titulo != direccion
                            ? Text(
                                direccion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          onSeleccionarDestino(resultado);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
