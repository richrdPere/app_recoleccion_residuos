import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_geometrical_background.dart';

class CiudadanoInicioContent extends StatelessWidget {
  final CiudadanoInicioState state;
  final String? nombres;

  final VoidCallback onRefresh;
  final ValueChanged<int> onSelectDomicilio;
  final VoidCallback onRetryCronograma;
  final VoidCallback onOpenCuenta;
  final VoidCallback onOpenMapa;

  const CiudadanoInicioContent({
    super.key,
    required this.state,
    this.nombres,
    required this.onRefresh,
    required this.onSelectDomicilio,
    required this.onRetryCronograma,
    required this.onOpenCuenta,
    required this.onOpenMapa,
  });

  // *********************************************************
  // 1. FORMATO DE TEXTOS
  // *********************************************************

  String _label(String value) {
    final text = value.replaceAll('_', ' ').trim();

    if (text.isEmpty) return '';

    return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
  }

  String _fecha(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) return value;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _hora(String value) {
    // El backend entrega HH:mm:ss.
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  // *********************************************************
  // 2. INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final nombre = nombres?.trim();
    final saludo = nombre == null || nombre.isEmpty
        ? 'Bienvenido'
        : 'Hola, $nombre';

    final domicilio = state.domicilioSeleccionado;
    final cronograma = state.cronograma;
    final proxima = cronograma?.proximaRecoleccion;

    return Scaffold(
      backgroundColor: colors.primary,
      body: AppGeometricalBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final horizontalPadding = compact ? 20.0 : 28.0;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // *************************************
                      // ENCABEZADO
                      // *************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          24,
                          horizontalPadding,
                          28,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    saludo,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Consulta la recolección '
                                    'para tu domicilio.',
                                    style: textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Municipalidad Provincial de Calca',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'Actualizar información',
                              onPressed: state.isLoading ? null : onRefresh,
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                      ),

                      // *************************************
                      // PANEL PRINCIPAL
                      // *************************************
                      Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(compact ? 48 : 72),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          32,
                          horizontalPadding,
                          24 + MediaQuery.of(context).padding.bottom,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // CARGA GENERAL
                                if (state.status ==
                                        CiudadanoInicioStatus.initial ||
                                    state.isLoading)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 48),
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 20),
                                        Text('Consultando tu servicio…'),
                                      ],
                                    ),
                                  )
                                // ERROR GENERAL
                                else if (state.isFailure)
                                  _InicioMessageCard(
                                    icon: Icons.error_outline_rounded,
                                    title: 'No pudimos cargar la información',
                                    message:
                                        state.errorMessage ??
                                        'Inténtalo nuevamente.',
                                    actionLabel: 'Reintentar',
                                    onAction: onRefresh,
                                  )
                                // SIN DOMICILIOS
                                else if (state.isEmpty)
                                  _InicioMessageCard(
                                    icon: Icons.home_outlined,
                                    title: 'Aún no tienes domicilios',
                                    message:
                                        'Necesitas registrar un domicilio '
                                        'para consultar el cronograma '
                                        'que le corresponde.',
                                    actionLabel: 'Ir a Mi cuenta',
                                    onAction: onOpenCuenta,
                                  )
                                // DOMICILIO SELECCIONADO
                                else if (domicilio != null) ...[
                                  Text(
                                    'Tu domicilio',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Card(
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              isExpanded: true,
                                              value:
                                                  state.idDomicilioSeleccionado,
                                              items: state.domicilios.map((
                                                item,
                                              ) {
                                                return DropdownMenuItem<int>(
                                                  value: item.idDomicilio,
                                                  child: Text(
                                                    item.esPrincipal
                                                        ? '${item.nombreDomicilio} '
                                                              '(principal)'
                                                        : item.nombreDomicilio,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  onSelectDomicilio(value);
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            domicilio.direccion,
                                            style: textTheme.bodyMedium,
                                          ),
                                          if (domicilio.referencia
                                                  ?.trim()
                                                  .isNotEmpty ??
                                              false) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              domicilio.referencia!,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        colors.onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Text(
                                            'Sector: '
                                            '${domicilio.zona?.nombre ?? "Sin asignar"}',
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Ruta: '
                                            '${domicilio.ruta?.nombre ?? "Sin asignar"}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  Text(
                                    'Próxima recolección',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // CARGA DEL CRONOGRAMA
                                  if (state.isCronogramaLoading ||
                                      state.cronogramaStatus ==
                                          CiudadanoInicioCronogramaStatus
                                              .initial)
                                    const Card(
                                      margin: EdgeInsets.zero,
                                      child: Padding(
                                        padding: EdgeInsets.all(28),
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text('Consultando horarios…'),
                                          ],
                                        ),
                                      ),
                                    )
                                  // ERROR DEL CRONOGRAMA
                                  else if (state.isCronogramaFailure)
                                    _InicioMessageCard(
                                      icon: Icons.event_busy_outlined,
                                      title: 'Cronograma no disponible',
                                      message:
                                          state.cronogramaErrorMessage ??
                                          'No se pudo consultar '
                                              'el cronograma.',
                                      actionLabel: 'Reintentar',
                                      onAction: onRetryCronograma,
                                    )
                                  // CRONOGRAMA CONSULTADO
                                  else if (cronograma != null) ...[
                                    Card(
                                      margin: EdgeInsets.zero,
                                      color: colors.primaryContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.local_shipping_outlined,
                                              size: 36,
                                              color: colors.onPrimaryContainer,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              proxima == null
                                                  ? 'Sin próxima '
                                                        'recolección disponible'
                                                  : '${_label(proxima.diaSemana)} '
                                                        '${_fecha(proxima.fecha)}',
                                              style: textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: colors
                                                        .onPrimaryContainer,
                                                  ),
                                            ),
                                            if (proxima != null) ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                '${_hora(proxima.horaInicio)}'
                                                ' – '
                                                '${_hora(proxima.horaFin)}',
                                                style: textTheme.titleMedium
                                                    ?.copyWith(
                                                      color: colors
                                                          .onPrimaryContainer,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _label(proxima.frecuencia),
                                                style: TextStyle(
                                                  color:
                                                      colors.onPrimaryContainer,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'El rango horario corresponde al '
                                      'servicio de la ruta, no a una hora '
                                      'exacta de llegada a tu domicilio.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // HORARIOS
                                    Text(
                                      'Horarios de tu ruta',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (cronograma.horarios.isEmpty)
                                      const Text(
                                        'No hay horarios disponibles '
                                        'para este domicilio.',
                                      )
                                    else
                                      Card(
                                        margin: EdgeInsets.zero,
                                        child: Column(
                                          children: cronograma.horarios.map((
                                            horario,
                                          ) {
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.schedule_rounded,
                                              ),
                                              title: Text(
                                                _label(horario.diaSemana),
                                              ),
                                              subtitle: Text(
                                                '${_hora(horario.horaInicio)}'
                                                ' – '
                                                '${_hora(horario.horaFin)}'
                                                '\n'
                                                '${_label(horario.frecuencia)}'
                                                '${horario.estado ? "" : " · Inactivo"}',
                                              ),
                                              isThreeLine: true,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],

                                  const SizedBox(height: 28),

                                  // ACCESO A LA PESTAÑA MAPA
                                  OutlinedButton.icon(
                                    onPressed: onOpenMapa,
                                    icon: const Icon(Icons.map_outlined),
                                    label: const Text('Abrir mapa'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        52,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// *********************************************************
// TARJETA DE ESTADO / ERROR
// *********************************************************

class _InicioMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _InicioMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
