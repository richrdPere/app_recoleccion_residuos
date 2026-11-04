import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

import '../bloc/ciudadano_calendario_state.dart';

class CiudadanoCalendarioContent extends StatefulWidget {
  final CiudadanoCalendarioState state;
  final ValueChanged<DateTime> onConsultarMes;
  final VoidCallback onSeleccionarMes;

  const CiudadanoCalendarioContent({
    super.key,
    required this.state,
    required this.onConsultarMes,
    required this.onSeleccionarMes,
  });

  @override
  State<CiudadanoCalendarioContent> createState() =>
      _CiudadanoCalendarioContentState();
}

class _CiudadanoCalendarioContentState
    extends State<CiudadanoCalendarioContent> {
  late DateTime _diaSeleccionado;

  static const _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const _dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  static const _colorHabitual = Color(0xFFB76A00);
  static const _colorServicio = Color(0xFF1565C0);
  static const _colorCancelado = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();

    _seleccionarDiaInicial();
  }

  @override
  void didUpdateWidget(covariant CiudadanoCalendarioContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final anterior = oldWidget.state.mes;
    final actual = widget.state.mes;

    if (anterior.year != actual.year || anterior.month != actual.month) {
      _seleccionarDiaInicial();
    }
  }

  DateTime _hoyPeru() {
    final peru = DateTime.now().toUtc().subtract(const Duration(hours: 5));

    return DateTime.utc(peru.year, peru.month, peru.day);
  }

  void _seleccionarDiaInicial() {
    final mes = widget.state.mes;
    final hoy = _hoyPeru();

    _diaSeleccionado = mes.year == hoy.year && mes.month == hoy.month
        ? hoy
        : DateTime.utc(mes.year, mes.month, 1);
  }

  String _claveFecha(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _hora(String value) =>
      value.length >= 5 ? value.substring(0, 5) : value;

  bool _mismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, List<CronogramaEventoModel>> _agruparEventos() {
    final resultado = <String, List<CronogramaEventoModel>>{};

    final eventos =
        widget.state.cronograma?.calendario ?? const <CronogramaEventoModel>[];

    for (final evento in eventos) {
      resultado
          .putIfAbsent(evento.fecha, () => <CronogramaEventoModel>[])
          .add(evento);
    }

    for (final lista in resultado.values) {
      lista.sort((a, b) {
        final comparacion = a.horaInicio.compareTo(b.horaInicio);

        return comparacion != 0
            ? comparacion
            : a.idEvento.compareTo(b.idEvento);
      });
    }

    return resultado;
  }

  Color _colorEvento(CronogramaEventoModel evento) {
    if (evento.esHorarioHabitual) return _colorHabitual;
    if (evento.estaCancelado) return _colorCancelado;
    if (evento.estaFinalizado) return Colors.green.shade700;
    if (evento.estaPausado) return Colors.orange.shade800;

    return _colorServicio;
  }

  Widget _leyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PuntoCalendario(color: color),
        const SizedBox(width: 6),
        Text(texto),
      ],
    );
  }

  Widget _cuadricula(Map<String, List<CronogramaEventoModel>> porFecha) {
    final mes = widget.state.mes;
    final hoy = _hoyPeru();

    final primerDia = DateTime.utc(mes.year, mes.month, 1);
    final cantidadDias = DateTime.utc(mes.year, mes.month + 1, 0).day;

    // Lunes = 0; domingo = 6.
    final desplazamiento = primerDia.weekday - 1;

    final cantidadCeldas = ((desplazamiento + cantidadDias + 6) ~/ 7) * 7;

    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: _dias
                  .map(
                    (dia) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          dia,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            GridView.builder(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cantidadCeldas,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 64,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final numero = index - desplazamiento + 1;

                if (numero < 1 || numero > cantidadDias) {
                  return const SizedBox.shrink();
                }

                final fecha = DateTime.utc(mes.year, mes.month, numero);

                final eventos =
                    porFecha[_claveFecha(fecha)] ??
                    const <CronogramaEventoModel>[];

                final seleccionado = _mismoDia(fecha, _diaSeleccionado);

                final esHoy = _mismoDia(fecha, hoy);

                final habituales = eventos
                    .where((evento) => evento.esHorarioHabitual)
                    .length;

                final servicios = eventos
                    .where(
                      (evento) =>
                          evento.esServicioProgramado && !evento.estaCancelado,
                    )
                    .length;

                final cancelados = eventos
                    .where(
                      (evento) =>
                          evento.esServicioProgramado && evento.estaCancelado,
                    )
                    .length;

                return Semantics(
                  button: true,
                  selected: seleccionado,
                  label:
                      '$numero de ${_meses[mes.month - 1]} '
                      'de ${mes.year}. '
                      '${esHoy ? "Hoy. " : ""}'
                      '$habituales referencias habituales, '
                      '$servicios servicios y '
                      '$cancelados cancelaciones.',
                  child: ExcludeSemantics(
                    child: Material(
                      color: seleccionado
                          ? colors.primaryContainer
                          : colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: seleccionado || esHoy
                              ? colors.primary
                              : colors.outlineVariant,
                          width: seleccionado ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          setState(() => _diaSeleccionado = fecha);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$numero',
                                    style: TextStyle(
                                      fontWeight: seleccionado || esHoy
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: seleccionado
                                          ? colors.onPrimaryContainer
                                          : colors.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 3,
                                runSpacing: 2,
                                children: [
                                  if (habituales > 0)
                                    const _PuntoCalendario(
                                      color: _colorHabitual,
                                    ),
                                  if (servicios > 0)
                                    const _PuntoCalendario(
                                      color: _colorServicio,
                                    ),
                                  if (cancelados > 0)
                                    const _PuntoCalendario(
                                      color: _colorCancelado,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEvento(CronogramaEventoModel evento) {
    final color = _colorEvento(evento);
    final habitual = evento.esHorarioHabitual;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  habitual
                      ? Icons.schedule_outlined
                      : evento.estaCancelado
                      ? Icons.event_busy_outlined
                      : Icons.local_shipping_outlined,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    habitual ? 'Horario habitual' : 'Servicio programado',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_hora(evento.horaInicio)}'
              ' – ${_hora(evento.horaFin)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                side: BorderSide(color: color),
                label: Text(evento.estadoLabel, style: TextStyle(color: color)),
              ),
            ),
            if (habitual)
              const Text('Horario de referencia, sujeto a programación.')
            else if (!evento.estaCancelado)
              const Text(
                'La franja del servicio no representa una hora '
                'exacta de llegada a tu domicilio.',
              ),
            if (evento.franjaVencida)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Franja horaria concluida'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final mes = state.mes;
    final data = state.cronograma;

    final porFecha = _agruparEventos();
    final eventosDelDia =
        porFecha[_claveFecha(_diaSeleccionado)] ??
        const <CronogramaEventoModel>[];

    final cargando =
        state.isLoading || state.status == CiudadanoCalendarioStatus.initial;

    final fallo = state.status == CiudadanoCalendarioStatus.failure;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de recolección'),
        actions: [
          IconButton(
            tooltip: 'Actualizar mes',
            onPressed: cargando ? null : () => widget.onConsultarMes(mes),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Mes anterior',
                        onPressed: mes.year == 2000 && mes.month == 1
                            ? null
                            : () => widget.onConsultarMes(
                                DateTime.utc(mes.year, mes.month - 1, 1),
                              ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: widget.onSeleccionarMes,
                          child: Text('${_meses[mes.month - 1]} ${mes.year}'),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Mes siguiente',
                        onPressed: mes.year == 2100 && mes.month == 12
                            ? null
                            : () => widget.onConsultarMes(
                                DateTime.utc(mes.year, mes.month + 1, 1),
                              ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                if (cargando) const LinearProgressIndicator(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      if (data != null) ...[
                        Text(
                          data.domicilio.nombreDomicilio,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (data.domicilio.ruta != null)
                          Text(data.domicilio.ruta!.nombre),
                        const SizedBox(height: 16),
                      ],

                      // Siempre visible, incluso mientras carga.
                      // El BLoC limpia los eventos del mes anterior.
                      _cuadricula(porFecha),

                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          _leyenda(_colorHabitual, 'Habitual'),
                          _leyenda(_colorServicio, 'Servicio'),
                          _leyenda(_colorCancelado, 'Cancelado'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Selecciona un día para consultar sus eventos. '
                        'Un horario habitual no confirma un servicio.',
                      ),
                      const SizedBox(height: 24),

                      Text(
                        '${_diaSeleccionado.day} de '
                        '${_meses[_diaSeleccionado.month - 1]} '
                        'de ${_diaSeleccionado.year}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      if (cargando)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Consultando eventos del mes…',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (fallo)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  state.errorMessage ??
                                      'No se pudo consultar el calendario.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: () {
                                    widget.onConsultarMes(mes);
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (eventosDelDia.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.event_available_outlined, size: 36),
                                SizedBox(height: 12),
                                Text(
                                  'No hay eventos para este día.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...eventosDelDia.map(_tarjetaEvento),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PuntoCalendario extends StatelessWidget {
  final Color color;

  const _PuntoCalendario({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
