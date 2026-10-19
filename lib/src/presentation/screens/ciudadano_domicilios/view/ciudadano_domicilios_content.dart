import 'package:flutter/material.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

enum _DomicilioMenuAction { edit, principal, delete }

class CiudadanoDomiciliosContent extends StatelessWidget {
  final CiudadanoDomiciliosState state;

  final VoidCallback onRefresh;
  final ValueChanged<bool> onToggleInactivos;
  final VoidCallback onCreate;
  final ValueChanged<GetMisDomiciliosDataModel> onEdit;
  final ValueChanged<GetMisDomiciliosDataModel> onSetPrincipal;
  final ValueChanged<GetMisDomiciliosDataModel> onDelete;
  final VoidCallback onBack;

  const CiudadanoDomiciliosContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onToggleInactivos,
    required this.onCreate,
    required this.onEdit,
    required this.onSetPrincipal,
    required this.onDelete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopScope(
      canPop: !state.isBusy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis domicilios'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'Volver',
            onPressed: state.isBusy ? null : onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          actions: [
            IconButton(
              tooltip: 'Actualizar domicilios',
              onPressed: state.isBusy ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: state.isBusy ? null : onCreate,
          icon: const Icon(Icons.add),
          label: const Text(''),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (state.isBusy) const LinearProgressIndicator(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tus direcciones de recolección',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Administra tus domicilios y elige '
                            'cuál utilizar como principal.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),

                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Incluir domicilios inactivos'),
                            value: state.incluirInactivos,
                            onChanged: state.isBusy ? null : onToggleInactivos,
                          ),
                          const SizedBox(height: 16),

                          // ERROR DEL LISTADO
                          if (state.status ==
                              CiudadanoDomiciliosStatus.failure) ...[
                            Card(
                              color: colors.errorContainer,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      state.errorMessage ??
                                          'No se pudieron consultar '
                                              'tus domicilios.',
                                      style: TextStyle(
                                        color: colors.onErrorContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: state.isBusy
                                          ? null
                                          : onRefresh,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Volver a consultar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // CARGA INICIAL
                          if (state.domicilios.isEmpty &&
                              (state.isLoading ||
                                  state.status ==
                                      CiudadanoDomiciliosStatus.initial))
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Consultando domicilios…'),
                                ],
                              ),
                            )
                          // LISTADO VACÍO
                          else if (state.isEmpty)
                            Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.home_outlined,
                                      size: 56,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay domicilios para mostrar',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Agrega un domicilio para '
                                      'consultar su cronograma '
                                      'de recolección.',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton.icon(
                                      onPressed: state.isBusy ? null : onCreate,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Registrar domicilio'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // TARJETAS
                          else
                            ...state.domicilios.map(
                              (domicilio) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _DomicilioCard(
                                  domicilio: domicilio,
                                  enabled: !state.isBusy,
                                  processing: state.isProcessingDomicilio(
                                    domicilio.idDomicilio,
                                  ),
                                  onEdit: () => onEdit(domicilio),
                                  onPrincipal: () => onSetPrincipal(domicilio),
                                  onDelete: () => onDelete(domicilio),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// *********************************************************
// TARJETA DE DOMICILIO
// *********************************************************

class _DomicilioCard extends StatelessWidget {
  final GetMisDomiciliosDataModel domicilio;
  final bool enabled;
  final bool processing;

  final VoidCallback onEdit;
  final VoidCallback onPrincipal;
  final VoidCallback onDelete;

  const _DomicilioCard({
    required this.domicilio,
    required this.enabled,
    required this.processing,
    required this.onEdit,
    required this.onPrincipal,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final referencia = domicilio.referencia?.trim();
    final activo = domicilio.estadoDomicilio == 'ACTIVO';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.home_outlined, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    domicilio.nombreDomicilio,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (processing)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  PopupMenuButton<_DomicilioMenuAction>(
                    enabled: enabled,
                    tooltip: 'Opciones del domicilio',
                    onSelected: (action) {
                      switch (action) {
                        case _DomicilioMenuAction.edit:
                          onEdit();
                          break;

                        case _DomicilioMenuAction.principal:
                          onPrincipal();
                          break;

                        case _DomicilioMenuAction.delete:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _DomicilioMenuAction.edit,
                        child: Text('Editar'),
                      ),
                      if (!domicilio.esPrincipal && activo)
                        const PopupMenuItem(
                          value: _DomicilioMenuAction.principal,
                          child: Text('Establecer como principal'),
                        ),
                      const PopupMenuItem(
                        value: _DomicilioMenuAction.delete,
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (domicilio.esPrincipal)
                  Chip(
                    avatar: const Icon(Icons.star_rounded, size: 18),
                    label: const Text('Principal'),
                    backgroundColor: colors.secondaryContainer,
                  ),
                Chip(
                  label: Text(activo ? 'Activo' : domicilio.estadoDomicilio),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(domicilio.direccion),

            if (referencia != null && referencia.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                referencia,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            Text('Sector: ${domicilio.zona?.nombre ?? "Sin asignar"}'),
            const SizedBox(height: 6),
            Text('Ruta: ${domicilio.ruta?.nombre ?? "Sin asignar"}'),
            const SizedBox(height: 6),
            Text(
              domicilio.ubicacionValidada
                  ? 'Ubicación validada'
                  : 'Ubicación pendiente de validación',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
