import 'package:flutter/material.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Widgets
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_bar_title_screen.dart';

class RecorridoContent extends StatelessWidget {
  final RecorridoState state;
  final bool puedeGestionar;
  final bool preparandoAccion;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onPausar;
  final Future<void> Function() onReanudar;
  final Future<void> Function() onFinalizar;
  final VoidCallback? onIrAInicio;

  const RecorridoContent({
    super.key,
    required this.state,
    required this.puedeGestionar,
    required this.preparandoAccion,
    required this.onRefresh,
    required this.onPausar,
    required this.onReanudar,
    required this.onFinalizar,
    this.onIrAInicio,
    
  });

  bool get _isBusy =>
      preparandoAccion || state.isLoadingActivo || state.isProcessingAccion;

  String? get _errorMessage {
    final response = state.activoResponse;

    if (response is ErrorData<ApiResponse<RecorridoDataModel?>>) {
      return response.message;
    }

    return null;
  }

  // *********************************************************
  // 1. INTERFAZ
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final recorrido = state.recorridoActivo;

    return Scaffold(
      appBar: AppBarTitleScreen(
        title: 'Mi recorrido',
        actions: [
          AppBarTitleAction(
            icon: Icons.refresh_rounded,
            tooltip: state.isLoadingActivo
                ? 'Actualizando recorrido...'
                : 'Actualizar recorrido',
            color: state.isLoadingActivo ? colors.primary : null,
            onPressed: () async {
              if (!_isBusy) await onRefresh();
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 360
                  ? 16.0
                  : 24.0;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isBusy) ...[
                            const LinearProgressIndicator(),
                            const SizedBox(height: 16),
                          ],
                          if (preparandoAccion) ...[
                            const Text('Preparando la acción...'),
                            const SizedBox(height: 16),
                          ],
                          if (recorrido == null)
                            _buildWithoutData(context)
                          else ...[
                            if (_errorMessage != null) ...[
                              Text(
                                'No se pudo actualizar. Se muestran '
                                'los últimos datos consultados.',
                                style: TextStyle(color: colors.error),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildHeader(context, recorrido),
                            const SizedBox(height: 20),
                            _buildInformation(context, recorrido),
                            const SizedBox(height: 20),
                            if (_errorMessage == null)
                              _buildActions(context, recorrido)
                            else
                              OutlinedButton.icon(
                                onPressed: _isBusy
                                    ? null
                                    : () async => await onRefresh(),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reintentar consulta'),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // *********************************************************
  // 2. SIN DATOS / ERROR INICIAL
  // *********************************************************
  Widget _buildWithoutData(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (state.isLoadingActivo) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('Consultando recorrido activo...')),
      );
    }

    final error = _errorMessage;

    if (error != null) {
      return Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 56, color: colors.error),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isBusy ? null : () async => await onRefresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }

    // No presenta el estado vacío antes de la primera consulta.
    if (state.activoResponse == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('Consultando estado del recorrido...')),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.route_outlined, size: 72, color: colors.primary),
          const SizedBox(height: 20),
          Text(
            'No tienes un recorrido activo',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Consulta tus programaciones en Inicio.',
            textAlign: TextAlign.center,
          ),
          if (onIrAInicio != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isBusy ? null : onIrAInicio,
              icon: const Icon(Icons.home_outlined),
              label: const Text('Ir a Inicio'),
            ),
          ],
        ],
      ),
    );
  }

  // *********************************************************
  // 3. CABECERA
  // *********************************************************
  Widget _buildHeader(BuildContext context, RecorridoDataModel recorrido) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 40,
              color: colors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Recorrido #${recorrido.idRecorrido}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Chip(label: Text(recorrido.estadoRecorrido.replaceAll('_', ' '))),
            const SizedBox(height: 8),
            Text(
              'Programación #${recorrido.idProgramacion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // *********************************************************
  // 4. INFORMACIÓN
  // *********************************************************
  Widget _buildInformation(BuildContext context, RecorridoDataModel recorrido) {
    final programacion = recorrido.programacion;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del recorrido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _dato('Ruta', '#${programacion.idRuta}'),
            _dato('Vehículo', '#${programacion.idVehiculo}'),
            _dato('Turno', programacion.turno.replaceAll('_', ' ')),
            _dato('Fecha programada', programacion.fechaProgramada),
            _dato(
              'Horario programado',
              '${programacion.horaInicioProgramada} – '
                  '${programacion.horaFinProgramada}',
            ),
            _dato('Inicio real', _fecha(recorrido.fechaHoraInicio)),
            _dato('Iniciado por', recorrido.usuarioInicio.username),
            if (recorrido.kilometrajeInicio != null)
              _dato(
                'Kilometraje inicial',
                '${recorrido.kilometrajeInicio!.toStringAsFixed(1)} km',
              ),
            if (recorrido.distanciaRecorridaMetros != null)
              _dato(
                'Distancia registrada',
                '${(recorrido.distanciaRecorridaMetros! / 1000).toStringAsFixed(2)} km',
              ),
            if (recorrido.observacionInicio?.isNotEmpty == true) ...[
              const Divider(height: 28),
              const Text(
                'Observación de inicio',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(recorrido.observacionInicio!),
            ],
          ],
        ),
      ),
    );
  }

  // *********************************************************
  // 5. ACCIONES
  // *********************************************************
  Widget _buildActions(BuildContext context, RecorridoDataModel recorrido) {
    if (!puedeGestionar) {
      return const Text(
        'La ejecución del recorrido corresponde al conductor autorizado.',
        textAlign: TextAlign.center,
      );
    }

    final estado = recorrido.estadoRecorrido.toUpperCase();
    final pausado = estado == 'PAUSADO';
    final enCurso = estado == 'EN_CURSO';

    if (!pausado && !enCurso) {
      return const Text(
        'El estado actual no permite ejecutar acciones.',
        textAlign: TextAlign.center,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _isBusy
              ? null
              : () async {
                  if (pausado) {
                    await onReanudar();
                  } else {
                    await onPausar();
                  }
                },
          icon: Icon(pausado ? Icons.play_arrow_rounded : Icons.pause_rounded),
          label: Text(pausado ? 'Reanudar recorrido' : 'Pausar recorrido'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isBusy ? null : () async => await onFinalizar(),
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Finalizar recorrido'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(titulo)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _fecha(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;

    String dos(int n) => n.toString().padLeft(2, '0');

    return '${dos(date.day)}/${dos(date.month)}/${date.year} '
        '${dos(date.hour)}:${dos(date.minute)}';
  }
}
