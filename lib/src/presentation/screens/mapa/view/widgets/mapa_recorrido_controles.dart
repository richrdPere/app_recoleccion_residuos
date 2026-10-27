import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class MapaRecorridoControles extends StatelessWidget {
  /// Programación seleccionada desde Home u otra pantalla.
  final int? idProgramacion;

  /// Estado del recorrido activo devuelto por el backend.
  final String? estadoRecorrido;

  /// Indica que la página está obteniendo GPS o preparando una acción.
  final bool preparandoAccion;

  final VoidCallback? onIniciar;
  final VoidCallback? onPausar;
  final VoidCallback? onReanudar;
  final VoidCallback? onFinalizar;

  const MapaRecorridoControles({
    super.key,
    this.idProgramacion,
    this.estadoRecorrido,
    this.preparandoAccion = false,
    this.onIniciar,
    this.onPausar,
    this.onReanudar,
    this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecorridoBloc, RecorridoState>(
      builder: (context, state) {
        final recorrido = state.recorridoActivo;

        final estado =  recorrido?.estadoRecorrido.trim().toUpperCase();

        // Ajustar estos valores si tu backend usa otros nombres.
        final enCurso = estado == 'EN_CURSO';
        final pausado = estado == 'PAUSADO';

        final ocupado =
            preparandoAccion ||
            state.isProcessingAccion ||
            state.isLoadingActivo;

        final consultaFallida =
            state.activoResponse is ErrorData<ApiResponse<RecorridoDataModel?>>;

        // Un resultado previo exitoso o un recorrido existente permiten
        // identificar la situación. Ante error se exige volver a consultar.
        final activoConsultado =
            state.activoResponse is Success<ApiResponse<RecorridoDataModel?>> ||
            recorrido != null;

        final puedeOperar = !ocupado && !consultaFallida && activoConsultado;

        final tieneProgramacion = idProgramacion != null && idProgramacion! > 0;

        final resultadoAccion = state.accionResponse;

        final String? errorAccion =
            resultadoAccion is ErrorData<ApiResponse<RecorridoDataModel>>
            ? resultadoAccion.fullMessage
            : null;

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recorrido == null
                            ? 'Operación del recorrido'
                            : 'Recorrido #${recorrido.idRecorrido}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!ocupado)
                      IconButton(
                        tooltip: 'Actualizar recorrido',
                        onPressed: () {
                          context.read<RecorridoBloc>().add(
                            const ObtenerRecorridoActivo(),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (ocupado) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(_mensajeCarga(state)),
                ] else if (consultaFallida) ...[
                  const Text(
                    'No se pudo verificar el recorrido activo. '
                    'Actualiza la consulta antes de operar.',
                  ),
                ] else if (!activoConsultado) ...[
                  const Text(
                    'Actualiza la consulta para comprobar '
                    'si tienes un recorrido activo.',
                  ),
                ] else if (recorrido == null) ...[
                  Text(
                    tieneProgramacion
                        ? 'Programación seleccionada: #$idProgramacion'
                        : 'Selecciona una programación para iniciar.',
                  ),
                ] else ...[
                  Text(
                    enCurso
                        ? 'Estado: en curso'
                        : pausado
                        ? 'Estado: pausado'
                        : 'Estado: ${estado ?? "sin verificar"}',
                  ),
                  if (!enCurso && !pausado) ...[
                    const SizedBox(height: 6),
                    const Text('No hay acciones disponibles para este estado.'),
                  ],
                ],

                if (errorAccion != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorAccion,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (recorrido == null)
                      FilledButton.icon(
                        onPressed: puedeOperar && tieneProgramacion
                            ? onIniciar
                            : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar recorrido'),
                      ),

                    if (recorrido != null && enCurso)
                      OutlinedButton.icon(
                        onPressed: puedeOperar ? onPausar : null,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pausar'),
                      ),

                    if (recorrido != null && pausado)
                      FilledButton.icon(
                        onPressed: puedeOperar ? onReanudar : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Reanudar'),
                      ),

                    if (recorrido != null && (enCurso || pausado))
                      FilledButton.icon(
                        onPressed: puedeOperar ? onFinalizar : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        ),
                        icon: const Icon(Icons.stop),
                        label: const Text('Finalizar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _mensajeCarga(RecorridoState state) {
    if (preparandoAccion) {
      return 'Preparando operación…';
    }

    if (state.isProcessingAccion) {
      switch (state.accion) {
        case RecorridoAccion.iniciar:
          return 'Iniciando recorrido…';
        case RecorridoAccion.pausar:
          return 'Pausando recorrido…';
        case RecorridoAccion.reanudar:
          return 'Reanudando recorrido…';
        case RecorridoAccion.finalizar:
          return 'Finalizando recorrido…';
        case null:
          return 'Procesando operación…';
      }
    }

    return 'Consultando recorrido activo…';
  }
}
