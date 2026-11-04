import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class CiudadanoDomicilioDetalleContent extends StatelessWidget {
  final GetMisDomiciliosDataModel domicilio;
  final VoidCallback onClose;

  const CiudadanoDomicilioDetalleContent({
    super.key,
    required this.domicilio,
    required this.onClose,
  });

  String _texto(String? value) {
    final text = value?.trim();

    return text == null || text.isEmpty ? 'No registrado' : text;
  }

  String _fecha(DateTime value) {
    final local = value.toLocal();

    String two(int number) => number.toString().padLeft(2, '0');

    return '${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final activo = domicilio.estadoDomicilio == 'ACTIVO';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Cerrar detalle',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Detalle del domicilio'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ENCABEZADO
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colors.primaryContainer,
                            child: Icon(
                              Icons.home_outlined,
                              size: 30,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            domicilio.nombreDomicilio,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                avatar: Icon(
                                  activo
                                      ? Icons.check_circle_outline
                                      : Icons.pause_circle_outline,
                                  size: 18,
                                ),
                                label: Text(
                                  activo ? 'Activo' : domicilio.estadoDomicilio,
                                ),
                              ),
                              if (domicilio.esPrincipal)
                                const Chip(
                                  avatar: Icon(Icons.star_rounded, size: 18),
                                  label: Text('Principal'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _Seccion(
                    titulo: 'Dirección',
                    children: [
                      _Dato(
                        icono: Icons.location_on_outlined,
                        titulo: 'Dirección del domicilio',
                        valor: domicilio.direccion,
                      ),
                      _Dato(
                        icono: Icons.near_me_outlined,
                        titulo: 'Referencia',
                        valor: _texto(domicilio.referencia),
                      ),
                      _Dato(
                        icono: Icons.notes_outlined,
                        titulo: 'Observación',
                        valor: _texto(domicilio.observacion),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _Seccion(
                    titulo: 'Servicio de recolección',
                    children: [
                      _Dato(
                        icono: Icons.grid_view_outlined,
                        titulo: 'Zona',
                        valor: domicilio.zona?.nombre ?? 'Sin asignar',
                      ),
                      _Dato(
                        icono: Icons.route_outlined,
                        titulo: 'Ruta',
                        valor: domicilio.ruta?.nombre ?? 'Sin asignar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _Seccion(
                    titulo: 'Ubicación',
                    children: [
                      _Dato(
                        icono: Icons.my_location_outlined,
                        titulo: 'Coordenadas',
                        valor:
                            'Latitud: ${domicilio.latitud.toStringAsFixed(7)}\n'
                            'Longitud: ${domicilio.longitud.toStringAsFixed(7)}',
                      ),
                      _Dato(
                        icono: Icons.map_outlined,
                        titulo: 'Origen de la ubicación',
                        valor: domicilio.origenUbicacion,
                      ),
                      if (domicilio.precisionUbicacion != null)
                        _Dato(
                          icono: Icons.gps_fixed,
                          titulo: 'Precisión registrada',
                          valor:
                              '${domicilio.precisionUbicacion!.toStringAsFixed(2)} m',
                        ),
                      _Dato(
                        icono: Icons.verified_outlined,
                        titulo: 'Validación administrativa',
                        valor: domicilio.ubicacionValidada
                            ? 'Ubicación validada'
                            : 'Pendiente de validación',
                      ),
                      if (domicilio.fechaValidacion != null)
                        _Dato(
                          icono: Icons.event_available_outlined,
                          titulo: 'Fecha de validación',
                          valor: _fecha(domicilio.fechaValidacion!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _Seccion(
                    titulo: 'Registro',
                    children: [
                      _Dato(
                        icono: Icons.calendar_today_outlined,
                        titulo: 'Fecha de creación',
                        valor: _fecha(domicilio.createdAt),
                      ),
                      _Dato(
                        icono: Icons.update,
                        titulo: 'Última actualización',
                        valor: _fecha(domicilio.updatedAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: onClose,
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _Seccion({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          titulo,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _Dato({required this.icono, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(valor, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
