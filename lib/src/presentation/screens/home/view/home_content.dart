import 'package:flutter/material.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Widgets
import 'widgets/home_header.dart';
import 'widgets/home_body.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_bar-title_screen.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/customs/custom_background_painter.dart';

class HomeContent extends StatelessWidget {
  final String nombreConductor;
  final DateTime fecha;

  final bool cargando;
  final MisAsignacionesDataModel? datos;
  final String? error;

  final VoidCallback onActualizar;
  final VoidCallback? onVerProgramaciones;
  final ValueChanged<MiAsignacionModel> onSeleccionarRecorrido;

  final bool bloqueandoRespuestas;
  final int? idAsignacionRespondiendo;

  final bool Function(MiAsignacionModel) puedeAceptarAsignacion;

  final ValueChanged<MiAsignacionModel> onAceptarAsignacion;

  const HomeContent({
    super.key,
    required this.nombreConductor,
    required this.fecha,
    required this.cargando,
    required this.datos,
    required this.error,
    required this.onActualizar,
    required this.bloqueandoRespuestas,
    required this.idAsignacionRespondiendo,
    required this.puedeAceptarAsignacion,
    required this.onAceptarAsignacion,
    this.onVerProgramaciones,
    required this.onSeleccionarRecorrido,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBarTitleScreen(
        title: 'SisRecolección',
        automaticallyImplyLeading: false,
        actions: [
          // AppBarTitleAction(
          //   icon: Icons.person,
          //   tooltip: 'Mi perfil',
          //   onPressed: () {
          //     context.go('/profile');
          //   },
          // ),
        ],
      ),
      body: Stack(
        children: [
          // ===============================================
          // FONDO IRREGULAR
          // ===============================================
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: CustomBackgroundPainter(
                    colorScheme: colorScheme,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ),

          // ===============================================
          // CONTENIDO
          // ===============================================
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                // final bloc = context.read<HomeBloc>();

                // bloc.add(const LoadPatrullajeActivo());

                // bloc.add(const RefreshMisPatrullajes());

                // await bloc.stream.firstWhere(
                //   (state) => !state.isLoading && !state.isLoadingMisPatrullajes,
                // );
              },
              child: Column(
                children: [
                  HomeHeader(
                    nombreConductor: nombreConductor,
                    fecha: fecha,
                    cargando: cargando,
                    onActualizar: onActualizar,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: HomeBody(
                      cargando: cargando,
                      datos: datos,
                      error: error,
                      onActualizar: onActualizar,
                      onVerProgramaciones: onVerProgramaciones,
                      bloqueandoRespuestas: bloqueandoRespuestas,
                      idAsignacionRespondiendo: idAsignacionRespondiendo,
                      puedeAceptarAsignacion: puedeAceptarAsignacion,
                      onAceptarAsignacion: onAceptarAsignacion,
                      onSeleccionarRecorrido: onSeleccionarRecorrido
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
