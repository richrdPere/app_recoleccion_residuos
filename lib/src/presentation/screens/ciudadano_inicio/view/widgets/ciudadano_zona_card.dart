import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/ciudadanos/get_mis_domicilios_model.dart';

class CiudadanoZonaCard extends StatelessWidget {
  final List<GetMisDomiciliosDataModel> domicilios;
  final int? idDomicilioSeleccionado;

  final bool cargando;
  final String? error;

  final ValueChanged<int> onSeleccionarDomicilio;
  final VoidCallback onAbrirCuenta;
  final VoidCallback? onReintentar;

  const CiudadanoZonaCard({
    super.key,
    required this.domicilios,
    required this.idDomicilioSeleccionado,
    required this.onSeleccionarDomicilio,
    required this.onAbrirCuenta,
    this.cargando = false,
    this.error,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    GetMisDomiciliosDataModel? seleccionado;

    for (final domicilio in domicilios) {
      if (domicilio.idDomicilio == idDomicilioSeleccionado) {
        seleccionado = domicilio;
        break;
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.home_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mi zona de recolección',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            if (cargando) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],

            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: TextStyle(color: colors.error)),
              if (onReintentar != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: cargando ? null : onReintentar,
                    child: const Text('Reintentar'),
                  ),
                ),
            ],

            if (domicilios.isEmpty) ...[
              const SizedBox(height: 16),
              Text(
                cargando
                    ? 'Consultando tus domicilios...'
                    : error != null
                    ? 'Tus domicilios no están disponibles.'
                    : 'Registra un domicilio para consultar '
                          'la recolección de tu zona.',
              ),
              if (!cargando && error == null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onAbrirCuenta,
                  icon: const Icon(Icons.add_home_outlined),
                  label: const Text('Registrar domicilio'),
                ),
              ],
            ] else ...[
              const SizedBox(height: 16),

              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: seleccionado?.idDomicilio,
                  hint: const Text('Selecciona un domicilio'),
                  borderRadius: BorderRadius.circular(16),
                  items: [
                    for (final domicilio in domicilios)
                      DropdownMenuItem<int>(
                        value: domicilio.idDomicilio,
                        child: Text(
                          domicilio.esPrincipal
                              ? '${domicilio.nombreDomicilio} · Principal'
                              : domicilio.nombreDomicilio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: cargando
                      ? null
                      : (id) {
                          if (id != null && id != idDomicilioSeleccionado) {
                            onSeleccionarDomicilio(id);
                          }
                        },
                ),
              ),

              if (seleccionado != null) ...[
                const SizedBox(height: 8),

                Text(seleccionado.direccion, style: theme.textTheme.bodyMedium),

                if (seleccionado.referencia?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    seleccionado.referencia!.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.location_on_outlined, size: 18),
                      label: Text(
                        seleccionado.zona?.nombre ?? 'Zona sin asignar',
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.route_outlined, size: 18),
                      label: Text(
                        seleccionado.ruta?.nombre ?? 'Ruta sin asignar',
                      ),
                    ),
                  ],
                ),
              ],

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onAbrirCuenta,
                  child: const Text('Gestionar mis domicilios'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
