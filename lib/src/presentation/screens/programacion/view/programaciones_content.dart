import 'package:flutter/material.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ProgramacionesContent extends StatelessWidget {
  final ProgramacionesState state;

  final String? fechaDesde;
  final String? fechaHasta;
  final String? estadoAsignacion;
  final String? estadoProgramacion;

  final VoidCallback onActualizar;
  final VoidCallback onSeleccionarFechas;
  final VoidCallback onMostrarHoy;
  final VoidCallback onLimpiarFiltros;

  final ValueChanged<int> onCambiarPagina;

  final void Function(
    MiAsignacionModel asignacion,
    RespuestaAsignacion respuesta,
  )
  onResponder;

  const ProgramacionesContent({
    super.key,
    required this.state,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.estadoAsignacion,
    required this.estadoProgramacion,
    required this.onActualizar,
    required this.onSeleccionarFechas,
    required this.onMostrarHoy,
    required this.onLimpiarFiltros,
    required this.onCambiarPagina,
    required this.onResponder,
  });

  bool get _ocupado =>
      state.cargandoAsignaciones || state.respondiendoAsignacion;

  bool get _tieneFiltros =>
      fechaDesde != null ||
      fechaHasta != null ||
      estadoAsignacion != null ||
      estadoProgramacion != null;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          _filtros(context),
          const Divider(height: 1),
          Expanded(child: _contenido(context)),
        ],
      ),
    );
  }

  // *********************************************************
  // FILTROS
  // *********************************************************

  Widget _filtros(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _ocupado ? null : onSeleccionarFechas,
                icon: const Icon(Icons.date_range),
                label: const Text('Fechas'),
              ),
              OutlinedButton(
                onPressed: _ocupado ? null : onMostrarHoy,
                child: const Text('Hoy'),
              ),
              IconButton(
                onPressed: _ocupado ? null : onActualizar,
                tooltip: 'Actualizar',
                icon: const Icon(Icons.refresh),
              ),
              if (_tieneFiltros)
                TextButton(
                  onPressed: _ocupado ? null : onLimpiarFiltros,
                  child: const Text('Limpiar filtros'),
                ),
            ],
          ),
          if (_tieneFiltros) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (fechaDesde != null)
                  Chip(label: Text('Desde: ${_fecha(fechaDesde!)}')),
                if (fechaHasta != null)
                  Chip(label: Text('Hasta: ${_fecha(fechaHasta!)}')),
                if (estadoAsignacion != null)
                  Chip(
                    label: Text(
                      'Asignación: '
                      '${_etiqueta(estadoAsignacion!)}',
                    ),
                  ),
                if (estadoProgramacion != null)
                  Chip(
                    label: Text(
                      'Programación: '
                      '${_etiqueta(estadoProgramacion!)}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // *********************************************************
  // ESTADOS DEL LISTADO
  // *********************************************************

  Widget _contenido(BuildContext context) {
    final recurso = state.misAsignaciones;

    if (recurso is Initial<ApiResponse<MisAsignacionesDataModel>> ||
        recurso is Loading<ApiResponse<MisAsignacionesDataModel>>) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recurso is ErrorData<ApiResponse<MisAsignacionesDataModel>>) {
      return _mensajeListado(
        icono: Icons.error_outline,
        mensaje: recurso.fullMessage,
      );
    }

    if (recurso is! Success<ApiResponse<MisAsignacionesDataModel>>) {
      return const SizedBox.shrink();
    }

    final response = recurso.data;

    if (!response.success) {
      return _mensajeListado(
        icono: Icons.error_outline,
        mensaje: response.message.trim().isEmpty
            ? 'No se pudieron obtener las asignaciones.'
            : response.message,
      );
    }

    final datos = response.data;

    if (datos == null) {
      return _mensajeListado(
        icono: Icons.error_outline,
        mensaje: 'La respuesta no contiene datos de asignaciones.',
      );
    }

    return _listado(context, datos);
  }

  // *********************************************************
  // LISTADO Y PAGINACIÓN
  // *********************************************************

  Widget _listado(BuildContext context, MisAsignacionesDataModel datos) {
    final pagination = datos.pagination;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${pagination.total} asignaciones encontradas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: datos.items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No tienes asignaciones para '
                      'los filtros seleccionados.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: datos.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _tarjeta(context, datos.items[index]);
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Página anterior',
                onPressed: !_ocupado && pagination.page > 1
                    ? () => onCambiarPagina(pagination.page - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  pagination.totalPages == 0
                      ? 'Sin páginas'
                      : 'Página ${pagination.page} '
                            'de ${pagination.totalPages}',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                tooltip: 'Página siguiente',
                onPressed: !_ocupado && pagination.hasNextPage
                    ? () => onCambiarPagina(pagination.page + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // *********************************************************
  // TARJETA
  // *********************************************************

  Widget _tarjeta(BuildContext context, MiAsignacionModel asignacion) {
    final programacion = asignacion.programacion;

    final respondiendo = state.estaRespondiendo(
      asignacion.idProgramacionPersonal,
    );

    final observacionProgramacion = programacion.observacion?.trim();

    final observacionAsignacion = asignacion.observacion?.trim();

    final motivoCancelacion = programacion.motivoCancelacion?.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Programación #${asignacion.idProgramacion}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text(_etiqueta(asignacion.estadoAsignacion))),
                Chip(label: Text(_etiqueta(programacion.estadoProgramacion))),
                if (asignacion.esPrincipal)
                  const Chip(label: Text('Principal')),
              ],
            ),

            const SizedBox(height: 8),

            Text('Fecha: ${_fecha(programacion.fechaProgramada)}'),
            Text(
              'Horario: '
              '${_hora(programacion.horaInicioProgramada)}'
              ' – '
              '${_hora(programacion.horaFinProgramada)}',
            ),
            Text('Turno: ${_etiqueta(programacion.turno)}'),
            Text('Función: ${_etiqueta(asignacion.funcion)}'),

            const Divider(height: 24),

            Text('Ruta: #${programacion.idRuta}'),
            Text('Versión: #${programacion.idRutaVersion}'),
            Text('Vehículo: #${programacion.idVehiculo}'),

            if (observacionProgramacion != null &&
                observacionProgramacion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Observación de programación: '
                '$observacionProgramacion',
              ),
            ],

            if (observacionAsignacion != null &&
                observacionAsignacion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Observación de asignación: '
                '$observacionAsignacion',
              ),
            ],

            if (motivoCancelacion != null && motivoCancelacion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Motivo de cancelación: $motivoCancelacion'),
            ],

            const SizedBox(height: 12),

            if (respondiendo)
              const LinearProgressIndicator()
            else
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<RespuestaAsignacion>(
                  enabled: !state.respondiendoAsignacion,
                  tooltip: 'Responder asignación',
                  onSelected: (respuesta) {
                    onResponder(asignacion, respuesta);
                  },
                  itemBuilder: (_) {
                    return RespuestaAsignacion.values.map((respuesta) {
                      return PopupMenuItem<RespuestaAsignacion>(
                        value: respuesta,
                        child: Text(_etiqueta(respuesta.value)),
                      );
                    }).toList();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.reply),
                        SizedBox(width: 8),
                        Text('Responder'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // *********************************************************
  // MENSAJE DE ERROR
  // *********************************************************

  Widget _mensajeListado({required IconData icono, required String mensaje}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 48),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onActualizar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // *********************************************************
  // FORMATO
  // *********************************************************

  String _etiqueta(String valor) {
    return valor.replaceAll('_', ' ');
  }

  String _fecha(String valor) {
    // Conserva la fecha calendario recibida, sin convertirla
    // a otra zona horaria.
    final coincidencia = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(valor);

    if (coincidencia == null) return valor;

    return '${coincidencia.group(3)}/'
        '${coincidencia.group(2)}/'
        '${coincidencia.group(1)}';
  }

  String _hora(String valor) {
    final coincidencia = RegExp(r'^(\d{2}):(\d{2})').firstMatch(valor);

    if (coincidencia == null) return valor;

    return '${coincidencia.group(1)}:'
        '${coincidencia.group(2)}';
  }
}
