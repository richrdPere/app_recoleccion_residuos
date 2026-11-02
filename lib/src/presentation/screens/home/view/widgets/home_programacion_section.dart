import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

import 'home_asignacion_card.dart';
import 'home_estado.dart';

class HomeProgramacionSection extends StatelessWidget {
  final bool cargando;
  final MisAsignacionesDataModel? datos;
  final String? error;

  final VoidCallback onActualizar;

  final bool bloqueandoRespuestas;
  final int? idAsignacionRespondiendo;

  final bool Function(MiAsignacionModel) puedeAceptarAsignacion;

  final ValueChanged<MiAsignacionModel> onAceptarAsignacion;

  final ValueChanged<MiAsignacionModel> onSeleccionarRecorrido;

  const HomeProgramacionSection({
    super.key,
    required this.cargando,
    required this.datos,
    required this.error,
    required this.onActualizar,
    required this.bloqueandoRespuestas,
    required this.idAsignacionRespondiendo,
    required this.puedeAceptarAsignacion,
    required this.onAceptarAsignacion,
    required this.onSeleccionarRecorrido,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final asignaciones = <MiAsignacionModel>[...?datos?.items]
      ..sort(
        (a, b) => a.programacion.horaInicioProgramada.compareTo(
          b.programacion.horaInicioProgramada,
        ),
      );

    final total = datos?.pagination.total;

    Widget contenido;

    if (cargando) {
      contenido = const HomeEstado(
        icono: Icons.assignment_outlined,
        titulo: 'Consultando tu programación',
        mensaje: 'Estamos actualizando los datos de tu jornada.',
        cargando: true,
      );
    } else if (error != null) {
      contenido = HomeEstado(
        icono: Icons.cloud_off_outlined,
        titulo: 'No pudimos cargar tu programación',
        mensaje: error!,
        textoAccion: 'Reintentar',
        onAccion: onActualizar,
      );
    } else if (datos == null) {
      contenido = HomeEstado(
        icono: Icons.info_outline,
        titulo: 'Información no disponible',
        mensaje: 'Actualiza para consultar tus asignaciones.',
        textoAccion: 'Actualizar',
        onAccion: onActualizar,
      );
    } else if (asignaciones.isEmpty) {
      contenido = HomeEstado(
        icono: Icons.event_available_outlined,
        titulo: 'Sin asignaciones para esta jornada',
        mensaje:
            'Cuando recibas una programación '
            'podrás revisarla y responder desde aquí.',
        textoAccion: 'Actualizar',
        onAccion: onActualizar,
      );
    } else {
      contenido = Column(
        children: [
          for (var i = 0; i < asignaciones.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            HomeAsignacionCard(
              key: ValueKey(asignaciones[i].idProgramacionPersonal),
              asignacion: asignaciones[i],
              mostrarAceptar: puedeAceptarAsignacion(asignaciones[i]),
              aceptando:
                  idAsignacionRespondiendo ==
                  asignaciones[i].idProgramacionPersonal,
              bloqueado: bloqueandoRespuestas,
              onAceptar: () {
                onAceptarAsignacion(asignaciones[i]);
              },
              onSeleccionarRecorrido: () {
                onSeleccionarRecorrido(asignaciones[i]);
              },
            ),
          ],
          if (total != null && total > asignaciones.length) ...[
            const SizedBox(height: 14),
            Text(
              'Mostrando ${asignaciones.length} '
              'de $total asignaciones.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mi programación',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (total != null && !cargando && error == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$total',
                    style: const TextStyle(
                      color: Color(0xFF006A9B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Revisa los datos de tu jornada antes de salir.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          contenido,
        ],
      ),
    );
  }
}
