import 'package:flutter/material.dart';

import 'home_operacion_item.dart';

class HomeOperaciones extends StatelessWidget {
  final VoidCallback? onVerIncidencias;
  final VoidCallback? onVerRecolecciones;
  final VoidCallback? onVerProgramaciones;
  final VoidCallback? onVerMas;

  final Color colorTexto;
  final Color colorIcono;

  const HomeOperaciones({
    super.key,
    this.onVerIncidencias,
    this.onVerRecolecciones,
    this.onVerProgramaciones,
    this.onVerMas,
    this.colorTexto = const Color(0xFF102A43),
    this.colorIcono = const Color(0xFF00AEEF),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // *************************************************
        // TÍTULO Y ACCESO A MÁS OPERACIONES
        // *************************************************
        Row(
          children: [
            Expanded(
              child: Text(
                'Tus operaciones',
                style: TextStyle(
                  color: colorTexto,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onVerMas,
              tooltip: 'Ver todas las operaciones',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorIcono,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.45),
                disabledForegroundColor: colorIcono.withValues(alpha: 0.45),
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.chevron_right_rounded, size: 32),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // *************************************************
        // ACCESOS RÁPIDOS
        // *************************************************
        LayoutBuilder(
          builder: (context, constraints) {
            const separacion = 8.0;

            // Ancho suficiente para cuatro accesos,
            // respetando el mínimo de HomeOperacionItem.
            final columnas = constraints.maxWidth >= 312
                ? 4
                : constraints.maxWidth >= 152
                ? 2
                : 1;

            final anchoCalculado =
                (constraints.maxWidth - separacion * (columnas - 1)) / columnas;

            Widget acceso({
              required IconData icono,
              required String titulo,
              required VoidCallback? onTap,
              required double ancho,
            }) {
              return HomeOperacionItem(
                icono: icono,
                titulo: titulo,
                onTap: onTap,
                ancho: ancho,
                colorIcono: colorIcono,
                colorTexto: colorTexto,
              );
            }

            List<Widget> operaciones(double ancho) {
              return [
                acceso(
                  icono: Icons.report_problem_outlined,
                  titulo: 'Incidencias',
                  onTap: onVerIncidencias,
                  ancho: ancho,
                ),
                acceso(
                  icono: Icons.recycling_rounded,
                  titulo: 'Recolecciones',
                  onTap: onVerRecolecciones,
                  ancho: ancho,
                ),
                acceso(
                  icono: Icons.event_note_outlined,
                  titulo: 'Programaciones anteriores',
                  onTap: onVerProgramaciones,
                  ancho: ancho,
                ),
                acceso(
                  icono: Icons.grid_view_rounded,
                  titulo: 'Más operaciones',
                  onTap: onVerMas,
                  ancho: ancho,
                ),
              ];
            }

            // Protección para un contenedor excepcionalmente
            // estrecho: HomeOperacionItem requiere ancho >= 72.
            if (anchoCalculado < 72) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in operaciones(88))
                      Padding(
                        padding: const EdgeInsets.only(right: separacion),
                        child: item,
                      ),
                  ],
                ),
              );
            }

            return Wrap(
              spacing: separacion,
              runSpacing: 8,
              children: operaciones(anchoCalculado),
            );
          },
        ),
      ],
    );
  }
}
