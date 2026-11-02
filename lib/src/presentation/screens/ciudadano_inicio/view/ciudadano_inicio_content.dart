import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';


// Widgets
import 'widgets/ciudadano_inicio_header.dart';
import 'widgets/ciudadano_operaciones.dart';
import 'widgets/ciudadano_zona_card.dart';
import 'widgets/ciudadano_proxima_recoleccion_card.dart';
import 'widgets/ciudadano_reportes_recientes.dart';

class CiudadanoInicioContent extends StatelessWidget {
  final CiudadanoInicioState state;
  final String? nombres;

  final Future<void> Function() onRefresh;
  final ValueChanged<int> onSelectDomicilio;
  final VoidCallback onRetryCronograma;
  final VoidCallback onOpenCuenta;
  final VoidCallback onOpenMapa;

  // Campana existente de notificaciones.
  final Widget? campana;

  // Reportes: datos y acciones proporcionados por el Page.
  final List<IncidenciaListadoModel>? reportes;
  final bool cargandoReportes;
  final String? errorReportes;

  final VoidCallback? onReportarIncidencia;
  final VoidCallback? onVerTodosReportes;
  final VoidCallback? onReintentarReportes;
  final ValueChanged<IncidenciaListadoModel>? onAbrirReporte;

  const CiudadanoInicioContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onSelectDomicilio,
    required this.onRetryCronograma,
    required this.onOpenCuenta,
    required this.onOpenMapa,
    this.nombres,
    this.campana,
    this.reportes,
    this.cargandoReportes = false,
    this.errorReportes,
    this.onReportarIncidencia,
    this.onVerTodosReportes,
    this.onReintentarReportes,
    this.onAbrirReporte,
  });

  bool get _cargandoInicio =>
      state.status == CiudadanoInicioStatus.initial || state.isLoading;

  // *********************************************************
  // HORARIOS EN MODAL INFERIOR
  // *********************************************************

  Future<void> _abrirHorarios(
    BuildContext context,
    GetDomicilioCronogramaDataModel cronograma,
  ) async {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = theme.colorScheme;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Horarios de tu ruta',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    cronograma.domicilio.nombreDomicilio,
                    style: theme.textTheme.titleSmall,
                  ),

                  if (cronograma.domicilio.ruta != null) ...[
                    const SizedBox(height: 4),
                    Text(cronograma.domicilio.ruta!.nombre),
                  ],

                  const SizedBox(height: 20),

                  if (cronograma.horarios.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No hay horarios disponibles para este domicilio.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    for (final horario in cronograma.horarios)
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        color: colors.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.schedule_rounded,
                            color: colors.primary,
                          ),
                          title: Text(_etiqueta(horario.diaSemana)),
                          subtitle: Text(
                            '${_hora(horario.horaInicio)}'
                            ' – ${_hora(horario.horaFin)}\n'
                            '${_etiqueta(horario.frecuencia)}'
                            '${horario.estado ? '' : ' · Inactivo'}',
                          ),
                          isThreeLine: true,
                        ),
                      ),

                  const SizedBox(height: 12),

                  Text(
                    'El horario corresponde al servicio de la ruta, '
                    'no a una hora exacta de llegada a tu domicilio.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // *********************************************************
  // INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final domicilio = state.domicilioSeleccionado;
    final cronogramaRecibido = state.cronograma;

    // No reutilizar el cronograma de otro domicilio.
    final cronograma =
        domicilio != null &&
            cronogramaRecibido?.domicilio.idDomicilio == domicilio.idDomicilio
        ? cronogramaRecibido
        : null;

    final puedeVerHorarios =
        !_cargandoInicio &&
        !state.isFailure &&
        !state.isCronogramaLoading &&
        !state.isCronogramaFailure &&
        cronograma != null;

    // null significa que los reportes todavía no se han consultado.
    final mostrarReportes =
        onVerTodosReportes != null &&
        onAbrirReporte != null &&
        (reportes != null || cargandoReportes || errorReportes != null);

    final fondo = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.035),
      colors.surface,
    );

    return Scaffold(
      backgroundColor: fondo,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          // El Header ya incorpora el SafeArea superior.
          padding: EdgeInsets.zero,
          children: [
            // ***************************************
            // BLOQUE SUPERIOR
            // ***************************************
            CiudadanoInicioHeader(
              nombre: nombres ?? '',
              campana:
                  campana ??
                  const IconButton(
                    tooltip: 'Notificaciones',
                    onPressed: null,
                    icon: Icon(Icons.notifications_none_rounded),
                  ),
            ),

            CiudadanoOperaciones(
              onVerMapa: onOpenMapa,
              onReportarIncidencia: onReportarIncidencia,
              onVerHorarios: puedeVerHorarios
                  ? () {
                      _abrirHorarios(context, cronograma);
                    }
                  : null,
            ),

            // ***************************************
            // TARJETAS PRINCIPALES
            // ***************************************
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tu servicio de recolección',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Actualizar información',
                              onPressed:
                                  _cargandoInicio || state.isCronogramaLoading
                                  ? null
                                  : () async {
                                      await onRefresh();
                                    },
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        CiudadanoZonaCard(
                          domicilios: state.domicilios,
                          idDomicilioSeleccionado:
                              state.idDomicilioSeleccionado,
                          cargando: _cargandoInicio,
                          error: state.isFailure
                              ? state.errorMessage ??
                                    'No se pudieron consultar tus domicilios.'
                              : null,
                          onSeleccionarDomicilio: onSelectDomicilio,
                          onAbrirCuenta: onOpenCuenta,
                          onReintentar: () async {
                            await onRefresh();
                          },
                        ),

                        if (!_cargandoInicio &&
                            !state.isFailure &&
                            domicilio != null) ...[
                          const SizedBox(height: 20),

                          CiudadanoProximaRecoleccionCard(
                            cronograma: cronograma,
                            cargando:
                                state.isCronogramaLoading ||
                                state.cronogramaStatus ==
                                    CiudadanoInicioCronogramaStatus.initial,
                            error: state.isCronogramaFailure
                                ? state.cronogramaErrorMessage ??
                                      'No se pudo consultar el cronograma.'
                                : null,
                            onReintentar: onRetryCronograma,
                            onVerMapa: onOpenMapa,
                          ),
                        ],

                        if (mostrarReportes) ...[
                          const SizedBox(height: 24),

                          CiudadanoReportesRecientes(
                            reportes:
                                reportes ?? const <IncidenciaListadoModel>[],
                            cargando: cargandoReportes,
                            error: errorReportes,
                            onAbrirReporte: onAbrirReporte!,
                            onVerTodos: onVerTodosReportes!,
                            onReintentar: onReintentarReportes,
                            onCrearReporte: onReportarIncidencia,
                          ),
                        ],

                        const SizedBox(height: 24),

                        Text(
                          'Municipalidad Provincial de Calca',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
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
    );
  }

  String _etiqueta(String valor) {
    final texto = valor.replaceAll('_', ' ').trim().toLowerCase();

    if (texto.isEmpty) return 'No disponible';

    return '${texto[0].toUpperCase()}${texto.substring(1)}';
  }

  String _hora(String valor) {
    return valor.length >= 5 ? valor.substring(0, 5) : valor;
  }
}

// import 'package:flutter/material.dart';

// import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_geometrical_background.dart';

// class CiudadanoInicioContent extends StatelessWidget {
//   final CiudadanoInicioState state;
//   final String? nombres;

//   final VoidCallback onRefresh;
//   final ValueChanged<int> onSelectDomicilio;
//   final VoidCallback onRetryCronograma;
//   final VoidCallback onOpenCuenta;
//   final VoidCallback onOpenMapa;

//   const CiudadanoInicioContent({
//     super.key,
//     required this.state,
//     this.nombres,
//     required this.onRefresh,
//     required this.onSelectDomicilio,
//     required this.onRetryCronograma,
//     required this.onOpenCuenta,
//     required this.onOpenMapa,
//   });

//   // *********************************************************
//   // 1. FORMATO DE TEXTOS
//   // *********************************************************

//   String _label(String value) {
//     final text = value.replaceAll('_', ' ').trim();

//     if (text.isEmpty) return '';

//     return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
//   }

//   String _fecha(String value) {
//     final date = DateTime.tryParse(value);

//     if (date == null) return value;

//     final day = date.day.toString().padLeft(2, '0');
//     final month = date.month.toString().padLeft(2, '0');

//     return '$day/$month/${date.year}';
//   }

//   String _hora(String value) {
//     // El backend entrega HH:mm:ss.
//     return value.length >= 5 ? value.substring(0, 5) : value;
//   }

//   // *********************************************************
//   // 2. INTERFAZ
//   // *********************************************************

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final textTheme = theme.textTheme;

//     final nombre = nombres?.trim();
//     final saludo = nombre == null || nombre.isEmpty
//         ? 'Bienvenido'
//         : 'Hola, $nombre';

//     final domicilio = state.domicilioSeleccionado;
//     final cronograma = state.cronograma;
//     final proxima = cronograma?.proximaRecoleccion;

//     return Scaffold(
//       backgroundColor: colors.primary,
//       body: AppGeometricalBackground(
//         child: SafeArea(
//           bottom: false,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final compact = constraints.maxWidth < 360;
//               final horizontalPadding = compact ? 20.0 : 28.0;

//               return SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // *************************************
//                       // ENCABEZADO
//                       // *************************************
//                       Padding(
//                         padding: EdgeInsets.fromLTRB(
//                           horizontalPadding,
//                           24,
//                           horizontalPadding,
//                           28,
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     saludo,
//                                     style: textTheme.headlineSmall?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Consulta la recolección '
//                                     'para tu domicilio.',
//                                     style: textTheme.bodyMedium,
//                                   ),
//                                   const SizedBox(height: 12),
//                                   Text(
//                                     'Municipalidad Provincial de Calca',
//                                     style: textTheme.bodySmall,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton.filledTonal(
//                               tooltip: 'Actualizar información',
//                               onPressed: state.isLoading ? null : onRefresh,
//                               icon: const Icon(Icons.refresh_rounded),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // *************************************
//                       // PANEL PRINCIPAL
//                       // *************************************
//                       Container(
//                         decoration: BoxDecoration(
//                           color: theme.scaffoldBackgroundColor,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(compact ? 48 : 72),
//                           ),
//                         ),
//                         padding: EdgeInsets.fromLTRB(
//                           horizontalPadding,
//                           32,
//                           horizontalPadding,
//                           24 + MediaQuery.of(context).padding.bottom,
//                         ),
//                         child: Center(
//                           child: ConstrainedBox(
//                             constraints: const BoxConstraints(maxWidth: 600),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 // CARGA GENERAL
//                                 if (state.status ==
//                                         CiudadanoInicioStatus.initial ||
//                                     state.isLoading)
//                                   const Padding(
//                                     padding: EdgeInsets.symmetric(vertical: 48),
//                                     child: Column(
//                                       children: [
//                                         CircularProgressIndicator(),
//                                         SizedBox(height: 20),
//                                         Text('Consultando tu servicio…'),
//                                       ],
//                                     ),
//                                   )
//                                 // ERROR GENERAL
//                                 else if (state.isFailure)
//                                   _InicioMessageCard(
//                                     icon: Icons.error_outline_rounded,
//                                     title: 'No pudimos cargar la información',
//                                     message:
//                                         state.errorMessage ??
//                                         'Inténtalo nuevamente.',
//                                     actionLabel: 'Reintentar',
//                                     onAction: onRefresh,
//                                   )
//                                 // SIN DOMICILIOS
//                                 else if (state.isEmpty)
//                                   _InicioMessageCard(
//                                     icon: Icons.home_outlined,
//                                     title: 'Aún no tienes domicilios',
//                                     message:
//                                         'Necesitas registrar un domicilio '
//                                         'para consultar el cronograma '
//                                         'que le corresponde.',
//                                     actionLabel: 'Ir a Mi cuenta',
//                                     onAction: onOpenCuenta,
//                                   )
//                                 // DOMICILIO SELECCIONADO
//                                 else if (domicilio != null) ...[
//                                   Text(
//                                     'Tu domicilio',
//                                     style: textTheme.titleMedium?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),

//                                   Card(
//                                     margin: EdgeInsets.zero,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(20),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.stretch,
//                                         children: [
//                                           DropdownButtonHideUnderline(
//                                             child: DropdownButton<int>(
//                                               isExpanded: true,
//                                               value:
//                                                   state.idDomicilioSeleccionado,
//                                               items: state.domicilios.map((
//                                                 item,
//                                               ) {
//                                                 return DropdownMenuItem<int>(
//                                                   value: item.idDomicilio,
//                                                   child: Text(
//                                                     item.esPrincipal
//                                                         ? '${item.nombreDomicilio} '
//                                                               '(principal)'
//                                                         : item.nombreDomicilio,
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 );
//                                               }).toList(),
//                                               onChanged: (value) {
//                                                 if (value != null) {
//                                                   onSelectDomicilio(value);
//                                                 }
//                                               },
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             domicilio.direccion,
//                                             style: textTheme.bodyMedium,
//                                           ),
//                                           if (domicilio.referencia
//                                                   ?.trim()
//                                                   .isNotEmpty ??
//                                               false) ...[
//                                             const SizedBox(height: 6),
//                                             Text(
//                                               domicilio.referencia!,
//                                               style: textTheme.bodySmall
//                                                   ?.copyWith(
//                                                     color:
//                                                         colors.onSurfaceVariant,
//                                                   ),
//                                             ),
//                                           ],
//                                           const SizedBox(height: 12),
//                                           Text(
//                                             'Sector: '
//                                             '${domicilio.zona?.nombre ?? "Sin asignar"}',
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             'Ruta: '
//                                             '${domicilio.ruta?.nombre ?? "Sin asignar"}',
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 24),

//                                   Text(
//                                     'Próxima recolección',
//                                     style: textTheme.titleMedium?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),

//                                   // CARGA DEL CRONOGRAMA
//                                   if (state.isCronogramaLoading ||
//                                       state.cronogramaStatus ==
//                                           CiudadanoInicioCronogramaStatus
//                                               .initial)
//                                     const Card(
//                                       margin: EdgeInsets.zero,
//                                       child: Padding(
//                                         padding: EdgeInsets.all(28),
//                                         child: Column(
//                                           children: [
//                                             CircularProgressIndicator(),
//                                             SizedBox(height: 16),
//                                             Text('Consultando horarios…'),
//                                           ],
//                                         ),
//                                       ),
//                                     )
//                                   // ERROR DEL CRONOGRAMA
//                                   else if (state.isCronogramaFailure)
//                                     _InicioMessageCard(
//                                       icon: Icons.event_busy_outlined,
//                                       title: 'Cronograma no disponible',
//                                       message:
//                                           state.cronogramaErrorMessage ??
//                                           'No se pudo consultar '
//                                               'el cronograma.',
//                                       actionLabel: 'Reintentar',
//                                       onAction: onRetryCronograma,
//                                     )
//                                   // CRONOGRAMA CONSULTADO
//                                   else if (cronograma != null) ...[
//                                     Card(
//                                       margin: EdgeInsets.zero,
//                                       color: colors.primaryContainer,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(24),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Icon(
//                                               Icons.local_shipping_outlined,
//                                               size: 36,
//                                               color: colors.onPrimaryContainer,
//                                             ),
//                                             const SizedBox(height: 16),
//                                             Text(
//                                               proxima == null
//                                                   ? 'Sin próxima '
//                                                         'recolección disponible'
//                                                   : '${_label(proxima.diaSemana)} '
//                                                         '${_fecha(proxima.fecha)}',
//                                               style: textTheme.titleLarge
//                                                   ?.copyWith(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: colors
//                                                         .onPrimaryContainer,
//                                                   ),
//                                             ),
//                                             if (proxima != null) ...[
//                                               const SizedBox(height: 12),
//                                               Text(
//                                                 '${_hora(proxima.horaInicio)}'
//                                                 ' – '
//                                                 '${_hora(proxima.horaFin)}',
//                                                 style: textTheme.titleMedium
//                                                     ?.copyWith(
//                                                       color: colors
//                                                           .onPrimaryContainer,
//                                                     ),
//                                               ),
//                                               const SizedBox(height: 6),
//                                               Text(
//                                                 _label(proxima.frecuencia),
//                                                 style: TextStyle(
//                                                   color:
//                                                       colors.onPrimaryContainer,
//                                                 ),
//                                               ),
//                                             ],
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Text(
//                                       'El rango horario corresponde al '
//                                       'servicio de la ruta, no a una hora '
//                                       'exacta de llegada a tu domicilio.',
//                                       style: textTheme.bodySmall?.copyWith(
//                                         color: colors.onSurfaceVariant,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 24),

//                                     // HORARIOS
//                                     Text(
//                                       'Horarios de tu ruta',
//                                       style: textTheme.titleMedium?.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     if (cronograma.horarios.isEmpty)
//                                       const Text(
//                                         'No hay horarios disponibles '
//                                         'para este domicilio.',
//                                       )
//                                     else
//                                       Card(
//                                         margin: EdgeInsets.zero,
//                                         child: Column(
//                                           children: cronograma.horarios.map((
//                                             horario,
//                                           ) {
//                                             return ListTile(
//                                               leading: const Icon(
//                                                 Icons.schedule_rounded,
//                                               ),
//                                               title: Text(
//                                                 _label(horario.diaSemana),
//                                               ),
//                                               subtitle: Text(
//                                                 '${_hora(horario.horaInicio)}'
//                                                 ' – '
//                                                 '${_hora(horario.horaFin)}'
//                                                 '\n'
//                                                 '${_label(horario.frecuencia)}'
//                                                 '${horario.estado ? "" : " · Inactivo"}',
//                                               ),
//                                               isThreeLine: true,
//                                             );
//                                           }).toList(),
//                                         ),
//                                       ),
//                                   ],

//                                   const SizedBox(height: 28),

//                                   // ACCESO A LA PESTAÑA MAPA
//                                   OutlinedButton.icon(
//                                     onPressed: onOpenMapa,
//                                     icon: const Icon(Icons.map_outlined),
//                                     label: const Text('Abrir mapa'),
//                                     style: OutlinedButton.styleFrom(
//                                       minimumSize: const Size(
//                                         double.infinity,
//                                         52,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// // *********************************************************
// // TARJETA DE ESTADO / ERROR
// // *********************************************************

// class _InicioMessageCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String message;
//   final String actionLabel;
//   final VoidCallback onAction;

//   const _InicioMessageCard({
//     required this.icon,
//     required this.title,
//     required this.message,
//     required this.actionLabel,
//     required this.onAction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Icon(icon, size: 48, color: theme.colorScheme.primary),
//             const SizedBox(height: 16),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(message, textAlign: TextAlign.center),
//             const SizedBox(height: 20),
//             FilledButton(onPressed: onAction, child: Text(actionLabel)),
//           ],
//         ),
//       ),
//     );
//   }
// }
