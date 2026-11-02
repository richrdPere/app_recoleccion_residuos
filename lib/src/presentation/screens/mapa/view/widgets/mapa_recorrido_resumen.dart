import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class MapaRecorridoResumen extends StatelessWidget {
  final RecorridoDataModel? recorrido;
  final ProgramacionDetalleDataModel? programacion;

  final int? idProgramacion;

  final bool cargando;
  final String? error;

  final VoidCallback? onActualizar;

  const MapaRecorridoResumen({
    super.key,
    this.recorrido,
    this.programacion,
    this.idProgramacion,
    this.cargando = false,
    this.error,
    this.onActualizar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final recorridoActual = recorrido;

    final programacionId =
        recorridoActual?.idProgramacion ??
        idProgramacion ??
        programacion?.idProgramacion;

    // Evitar mostrar el nombre/vehículo de otra programación
    // que haya quedado cargada en el BLoC.
    final detalle =
        programacion != null && programacion!.idProgramacion == programacionId
        ? programacion
        : null;

    final tieneProgramacion = programacionId != null && programacionId > 0;

    final tieneDatos = recorridoActual != null || tieneProgramacion;

    final nombreRuta = detalle?.ruta.nombre.trim();

    final titulo = nombreRuta != null && nombreRuta.isNotEmpty
        ? nombreRuta
        : recorridoActual != null
        ? 'Ruta #${recorridoActual.programacion.idRuta}'
        : tieneProgramacion
        ? 'Programación #$programacionId'
        : cargando
        ? 'Consultando tu servicio'
        : error != null
        ? 'Información no disponible'
        : 'Sin programación seleccionada';

    final estado =
        recorridoActual?.estadoRecorrido ?? detalle?.estadoProgramacion;

    final textoEstado = cargando
        ? 'Actualizando'
        : error != null
        ? 'Sin verificar'
        : estado != null
        ? _etiqueta(estado)
        : tieneProgramacion
        ? 'Sin iniciar'
        : 'Sin servicio';

    final colorEstado = cargando || error != null
        ? const Color(0xFF8A5700)
        : _colorEstado(estado);

    final horaInicio =
        recorridoActual?.programacion.horaInicioProgramada ??
        detalle?.horaInicioProgramada;

    final horaFin =
        recorridoActual?.programacion.horaFinProgramada ??
        detalle?.horaFinProgramada;

    final vehiculoId =
        recorridoActual?.programacion.idVehiculo ?? detalle?.idVehiculo;

    final distancia = recorridoActual?.distanciaRecorridaMetros;
    final duracion = recorridoActual?.duracionSegundos;

    return Material(
      color: colors.surface,
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // *********************************************
            // IDENTIFICACIÓN Y ESTADO
            // *********************************************
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFF007FB1),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recorridoActual != null
                            ? 'Recorrido #${recorridoActual.idRecorrido}'
                            : 'Mi servicio',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                if (onActualizar != null)
                  IconButton(
                    tooltip: 'Actualizar resumen',
                    onPressed: cargando ? null : onActualizar,
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    textoEstado,
                    style: TextStyle(
                      color: colorEstado,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (recorridoActual != null && tieneProgramacion)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Programación #$programacionId',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),

            if (cargando) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],

            // *********************************************
            // MENSAJE DE ERROR
            // *********************************************
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
              ),
            ],

            // *********************************************
            // INFORMACIÓN OPERATIVA
            // *********************************************
            if (tieneDatos) ...[
              const SizedBox(height: 12),

              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: [
                  if (horaInicio != null && horaFin != null)
                    _dato(
                      context,
                      icono: Icons.schedule_rounded,
                      texto:
                          '${_hora(horaInicio)}'
                          ' – ${_hora(horaFin)}',
                    ),

                  if (detalle != null)
                    _dato(
                      context,
                      icono: Icons.local_shipping_outlined,
                      texto: detalle.vehiculo.placa,
                    )
                  else if (vehiculoId != null)
                    _dato(
                      context,
                      icono: Icons.local_shipping_outlined,
                      texto: 'Vehículo #$vehiculoId',
                    ),
                ],
              ),

              // Métricas recibidas, sin simular un contador
              // ni calcular una distancia que el backend no envió.
              if (recorridoActual != null &&
                  (distancia != null || duracion != null)) ...[
                const Divider(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    if (distancia != null)
                      _dato(
                        context,
                        icono: Icons.route_outlined,
                        texto:
                            '${(distancia / 1000).toStringAsFixed(2)} km registrados',
                      ),

                    if (duracion != null)
                      _dato(
                        context,
                        icono: Icons.timer_outlined,
                        texto: '${_duracion(duracion)} registrados',
                      ),
                  ],
                ),
              ],

              if (recorridoActual == null && detalle != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Estimado de ruta: '
                  '${detalle.versionRuta.distanciaEstimadaKm.toStringAsFixed(2)} km'
                  ' · ${detalle.versionRuta.duracionEstimadaMin} min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ] else if (!cargando && error == null) ...[
              const SizedBox(height: 10),
              Text(
                'Selecciona una programación desde Inicio '
                'para preparar tu recorrido.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dato(
    BuildContext context, {
    required IconData icono,
    required String texto,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 17, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Text(texto, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  String _hora(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(value);

    if (match == null) return value;

    return '${match.group(1)}:${match.group(2)}';
  }

  String _duracion(int segundos) {
    final valor = segundos < 0 ? 0 : segundos;

    final horas = valor ~/ 3600;
    final minutos = (valor % 3600) ~/ 60;

    if (horas == 0) return '$minutos min';

    return '$horas h ${minutos.toString().padLeft(2, '0')} min';
  }

  String _etiqueta(String value) {
    final texto = value.replaceAll('_', ' ').trim();

    if (texto.isEmpty) return 'Sin definir';

    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Color _colorEstado(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'EN_CURSO':
        return const Color(0xFF006A9B);

      case 'PAUSADO':
        return const Color(0xFF8A5700);

      case 'ACEPTADA':
      case 'FINALIZADO':
        return const Color(0xFF187749);

      case 'CANCELADA':
      case 'CANCELADO':
        return const Color(0xFFB3261E);

      default:
        return const Color(0xFF52616B);
    }
  }
}
