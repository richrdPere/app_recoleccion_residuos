import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class CiudadanoMapaContent extends StatelessWidget {
  final Widget mapaBase;
  final List<GetMisDomiciliosDataModel> domicilios;
  final int? idDomicilio;
  final GetDomicilioServicioActivoDataModel? datos;

  final bool cargando;
  final String? error;

  final ValueChanged<int> onSeleccionarDomicilio;
  final VoidCallback onActualizar;
  final VoidCallback onAbrirCuenta;
  final VoidCallback onNotificaciones;

  final VoidCallback? onCentrarDomicilio;
  final VoidCallback? onCentrarCamion;

  const CiudadanoMapaContent({
    super.key,
    required this.mapaBase,
    required this.domicilios,
    required this.idDomicilio,
    required this.datos,
    required this.cargando,
    required this.error,
    required this.onSeleccionarDomicilio,
    required this.onActualizar,
    required this.onAbrirCuenta,
    required this.onNotificaciones,
    required this.onCentrarDomicilio,
    required this.onCentrarCamion,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final seleccionValida = domicilios.any((d) => d.idDomicilio == idDomicilio);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text('Mi recolección'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _boton(
              context,
              Icons.notifications_none_rounded,
              'Notificaciones',
              onNotificaciones,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: mapaBase),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                kToolbarHeight + 12,
                12,
                12,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.home_outlined, color: colors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: seleccionValida ? idDomicilio : null,
                                    hint: Text(
                                      cargando
                                          ? 'Consultando domicilios...'
                                          : 'Selecciona un domicilio',
                                    ),
                                    items: [
                                      for (final d in domicilios)
                                        DropdownMenuItem(
                                          value: d.idDomicilio,
                                          child: Text(
                                            d.nombreDomicilio,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                    onChanged: cargando
                                        ? null
                                        : (id) {
                                            if (id != null &&
                                                id != idDomicilio) {
                                              onSeleccionarDomicilio(id);
                                            }
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (cargando) ...[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(),
                      ],

                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _boton(
                                  context,
                                  Icons.home_outlined,
                                  'Centrar domicilio',
                                  onCentrarDomicilio,
                                ),
                                const SizedBox(height: 10),
                                _boton(
                                  context,
                                  Icons.local_shipping_outlined,
                                  'Ver última ubicación del camión',
                                  onCentrarCamion,
                                ),
                                const SizedBox(height: 10),
                                _boton(
                                  context,
                                  Icons.refresh_rounded,
                                  'Actualizar servicio',
                                  cargando ? null : onActualizar,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.45,
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _resumen(context),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen(BuildContext context) {
    final theme = Theme.of(context);
    final data = datos;

    if (cargando) {
      return const Text('Consultando el servicio de tu domicilio...');
    }

    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'No se pudo consultar el servicio',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(error!),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onActualizar,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (domicilios.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Registra un domicilio para consultar '
            'la recolección de tu zona.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onAbrirCuenta,
            child: const Text('Ir a Mi cuenta'),
          ),
        ],
      );
    }

    if (data == null) {
      return const Text('Selecciona un domicilio para consultar el servicio.');
    }

    final servicio = data.servicio;
    final ubicacion = servicio?.ultimaUbicacion;

    final mensaje = switch (data.situacion) {
      'SIN_RUTA' => 'Este domicilio aún no tiene una ruta asignada.',
      'SIN_SERVICIO_ACTIVO' =>
        'No hay un servicio activo para esta ruta en este momento.',
      'EN_CURSO' =>
        ubicacion == null
            ? 'El servicio está en curso, pero todavía '
                  'no hay una ubicación disponible.'
            : 'Servicio en curso. Se muestra la última ubicación registrada.',
      'PAUSADO' =>
        'El servicio está pausado. La ubicación mostrada '
            'corresponde al último registro disponible.',
      _ => 'Estado del servicio: ${data.situacion}',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          data.ruta?.nombre ?? data.domicilio.nombre,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Text(mensaje),

        if (servicio != null) ...[
          const SizedBox(height: 10),
          Text(
            'Horario programado: '
            '${_hora(servicio.horaInicioProgramada)}'
            ' – ${_hora(servicio.horaFinProgramada)}',
          ),
        ],

        if (ubicacion != null) ...[
          const SizedBox(height: 8),
          Text('Ubicación recibida: ${_fecha(ubicacion.fechaRecepcion)}'),
        ],

        if (data.ruta?.geometriaDeVersionVigente == true) ...[
          const SizedBox(height: 8),
          const Text('Se muestra la versión vigente de la ruta.'),
        ],

        const SizedBox(height: 12),

        Text(
          'Consulta: ${_fecha(data.fechaConsulta)}',
          style: theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 8),

        const Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [Text('🔵 Domicilio'), Text('🟠 Camión')],
        ),
      ],
    );
  }

  Widget _boton(
    BuildContext context,
    IconData icono,
    String tooltip,
    VoidCallback? onPressed,
  ) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.primary,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icono),
      ),
    );
  }

  String _hora(String value) =>
      value.length >= 5 ? value.substring(0, 5) : value;

  String _fecha(DateTime? value) {
    if (value == null) return 'Sin fecha disponible';

    final fecha = value.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}'
        ' ${dos(fecha.hour)}:${dos(fecha.minute)}';
  }
}
