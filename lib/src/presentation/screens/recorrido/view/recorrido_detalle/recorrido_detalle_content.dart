import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/historial/view/widgets/historial_recorrido_tile.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_bar_title_screen.dart';

class RecorridoDetalleContent extends StatelessWidget {
  final int idRecorrido;
  final RecorridoDataModel? recorrido;
  final MiRecorridoItemModel? resumenInicial;

  final bool cargando;
  final String? error;

  final Future<void> Function() onActualizar;

  const RecorridoDetalleContent({
    super.key,
    required this.idRecorrido,
    required this.recorrido,
    required this.cargando,
    required this.onActualizar,
    this.resumenInicial,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final detalle = recorrido;

    // Evita asociar información de otra programación.
    final resumen = resumenInicial;
    final resumenValido =
        resumen != null &&
        resumen.idRecorrido == idRecorrido &&
        (detalle == null || resumen.idProgramacion == detalle.idProgramacion);

    final nombreRuta = resumenValido
        ? resumen.programacion.ruta.nombre.trim()
        : '';

    final eventos =
        detalle == null
              ? <RecorridoEventoModel>[]
              : List<RecorridoEventoModel>.of(detalle.eventos)
          ..sort((a, b) {
            final fechaA = DateTime.tryParse(a.fechaEvento);
            final fechaB = DateTime.tryParse(b.fechaEvento);

            if (fechaA != null && fechaB != null) {
              final comparacion = fechaA.compareTo(fechaB);

              if (comparacion != 0) return comparacion;
            }

            return a.idRecorridoEvento.compareTo(b.idRecorridoEvento);
          });

    return Scaffold(
      appBar: AppBarTitleScreen(
        title: 'Detalle del recorrido',
        actions: [
          AppBarTitleAction(
            icon: Icons.refresh_rounded,
            tooltip: cargando ? 'Actualizando...' : 'Actualizar detalle',
            onPressed: cargando
                ? null
                : () async {
                    await onActualizar();
                  },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onActualizar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (cargando) ...[
                        const LinearProgressIndicator(),
                        const SizedBox(height: 16),
                      ],

                      // Encabezado disponible incluso durante la carga.
                      _DetalleSeccion(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recorrido #$idRecorrido',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nombreRuta.isNotEmpty
                                  ? nombreRuta
                                  : detalle != null
                                  ? 'Ruta #${detalle.programacion.idRuta}'
                                  : 'Detalle del recorrido',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (detalle != null) ...[
                              const SizedBox(height: 12),
                              HistorialRecorridoEstado(
                                estado: detalle.estadoRecorrido,
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (error != null) ...[
                        const SizedBox(height: 16),
                        _DetalleSeccion(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detalle == null
                                    ? 'No se pudo consultar el recorrido'
                                    : 'No se pudo actualizar el detalle',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(error!),
                              if (detalle != null) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Se muestran los últimos datos consultados.',
                                ),
                              ],
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: cargando
                                    ? null
                                    : () async {
                                        await onActualizar();
                                      },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (detalle == null && !cargando && error == null) ...[
                        const SizedBox(height: 32),
                        const Icon(Icons.search_off_rounded, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'No se encontró información del recorrido.',
                          textAlign: TextAlign.center,
                        ),
                      ],

                      if (detalle != null) ...[
                        const SizedBox(height: 16),

                        _DetalleSeccion(
                          titulo: 'Programación',
                          child: Column(
                            children: [
                              _dato(
                                'Programación',
                                '#${detalle.idProgramacion}',
                              ),
                              _dato('Ruta', '#${detalle.programacion.idRuta}'),
                              _dato(
                                'Vehículo',
                                '#${detalle.programacion.idVehiculo}',
                              ),
                              if (resumenValido)
                                _dato(
                                  'Placa según historial',
                                  _texto(resumen.programacion.vehiculo.placa),
                                ),
                              _dato(
                                'Fecha programada',
                                _fechaProgramada(
                                  detalle.programacion.fechaProgramada,
                                ),
                              ),
                              _dato(
                                'Horario programado',
                                '${detalle.programacion.horaInicioProgramada}'
                                    ' – ${detalle.programacion.horaFinProgramada}',
                              ),
                              _dato(
                                'Turno',
                                _etiqueta(detalle.programacion.turno),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _DetalleSeccion(
                          titulo: 'Tiempos y distancia',
                          child: Column(
                            children: [
                              _dato('Inicio', _fecha(detalle.fechaHoraInicio)),
                              _dato(
                                'Finalización',
                                _fecha(detalle.fechaHoraFinalizacion),
                              ),
                              _dato(
                                'Duración registrada',
                                _duracion(detalle.duracionSegundos),
                              ),
                              _dato(
                                'Distancia registrada',
                                _distancia(detalle.distanciaRecorridaMetros),
                              ),
                              _dato(
                                'Kilometraje inicial',
                                _kilometraje(detalle.kilometrajeInicio),
                              ),
                              _dato(
                                'Kilometraje final',
                                _kilometraje(detalle.kilometrajeFinal),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _DetalleSeccion(
                          titulo: 'Registro de usuarios',
                          child: Column(
                            children: [
                              _dato(
                                'Inicio registrado por',
                                _texto(detalle.usuarioInicio.username),
                              ),
                              _dato(
                                'Finalización registrada por',
                                _texto(detalle.usuarioFinalizacion?.username),
                              ),
                            ],
                          ),
                        ),

                        if (_tieneObservaciones(detalle)) ...[
                          const SizedBox(height: 16),
                          _DetalleSeccion(
                            titulo: 'Observaciones',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_tieneTexto(detalle.observacionInicio))
                                  _observacion(
                                    context,
                                    'Al iniciar',
                                    detalle.observacionInicio!,
                                  ),
                                if (_tieneTexto(
                                  detalle.observacionFinalizacion,
                                ))
                                  _observacion(
                                    context,
                                    'Al finalizar',
                                    detalle.observacionFinalizacion!,
                                  ),
                                if (_tieneTexto(detalle.motivoCancelacion))
                                  _observacion(
                                    context,
                                    'Motivo de cancelación',
                                    detalle.motivoCancelacion!,
                                  ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        _DetalleSeccion(
                          titulo: 'Eventos del recorrido',
                          child: eventos.isEmpty
                              ? const Text('No hay eventos registrados.')
                              : Column(
                                  children: [
                                    for (final evento in eventos)
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          _iconoEvento(evento.tipoEvento),
                                          color: colors.primary,
                                        ),
                                        title: Text(
                                          _etiqueta(evento.tipoEvento),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_fecha(evento.fechaEvento)),
                                            Text(
                                              'Registrado por: '
                                              '${_texto(evento.usuario.username)}',
                                            ),
                                            if (_tieneTexto(
                                              evento.observacion,
                                            )) ...[
                                              const SizedBox(height: 4),
                                              Text(evento.observacion!.trim()),
                                            ],
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Las fechas y horas se muestran en la hora local '
                          'del dispositivo. La duración y distancia '
                          'corresponden a los valores registrados.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo),
          const SizedBox(height: 3),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _observacion(BuildContext context, String titulo, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(texto.trim()),
        ],
      ),
    );
  }

  bool _tieneTexto(String? valor) => valor?.trim().isNotEmpty == true;

  bool _tieneObservaciones(RecorridoDataModel detalle) =>
      _tieneTexto(detalle.observacionInicio) ||
      _tieneTexto(detalle.observacionFinalizacion) ||
      _tieneTexto(detalle.motivoCancelacion);

  String _texto(String? valor) =>
      _tieneTexto(valor) ? valor!.trim() : 'No registrado';

  String _etiqueta(String valor) => valor.replaceAll('_', ' ');

  String _fecha(String? valor) {
    if (valor == null) return 'No registrada';

    final fecha = DateTime.tryParse(valor)?.toLocal();
    if (fecha == null) return 'Fecha no disponible';

    String dos(int numero) => numero.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}'
        ' · ${dos(fecha.hour)}:${dos(fecha.minute)}';
  }

  // Es una fecha de calendario: no se convierte de zona horaria.
  String _fechaProgramada(String valor) {
    final fecha = DateTime.tryParse(valor);
    if (fecha == null) return valor;

    String dos(int numero) => numero.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}';
  }

  String _duracion(int? segundos) {
    if (segundos == null || segundos < 0) return 'No registrada';

    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final restantes = segundos % 60;

    if (horas > 0) return '${horas} h ${minutos} min';
    if (minutos > 0) return '$minutos min $restantes s';

    return '$restantes s';
  }

  String _distancia(double? metros) {
    if (metros == null || !metros.isFinite || metros < 0) {
      return 'No registrada';
    }

    if (metros < 1000) return '${metros.toStringAsFixed(0)} m';

    return '${(metros / 1000).toStringAsFixed(2)} km';
  }

  String _kilometraje(double? valor) {
    if (valor == null || !valor.isFinite || valor < 0) {
      return 'No registrado';
    }

    return '${valor.toStringAsFixed(2)} km';
  }

  IconData _iconoEvento(String tipo) {
    return switch (tipo.toUpperCase()) {
      'INICIO' => Icons.play_circle_outline_rounded,
      'PAUSA' => Icons.pause_circle_outline_rounded,
      'REANUDACION' => Icons.play_arrow_rounded,
      'FINALIZACION' => Icons.check_circle_outline_rounded,
      'CANCELACION' => Icons.cancel_outlined,
      _ => Icons.history_rounded,
    };
  }
}

class _DetalleSeccion extends StatelessWidget {
  final String? titulo;
  final Widget child;

  const _DetalleSeccion({this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (titulo != null) ...[
              Text(
                titulo!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
