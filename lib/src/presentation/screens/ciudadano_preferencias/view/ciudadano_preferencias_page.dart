import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/injection.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import '../bloc/ciudadano_preferencias_bloc.dart';
import '../bloc/ciudadano_preferencias_event.dart';
import '../bloc/ciudadano_preferencias_state.dart';

import 'ciudadano_preferencias_content.dart';

class CiudadanoPreferenciasPage extends StatelessWidget {
  const CiudadanoPreferenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = context.read<CiudadanoCuentaBloc>().state.perfil;

    if (perfil == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preferencias de avisos')),
        body: const Center(
          child: Text('Consulta primero tu perfil ciudadano.'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => CiudadanoPreferenciasBloc(
        useCases: locator<PrefNotificationUseCases>(),
        idCiudadano: perfil.idCiudadano,
      )..add(const CiudadanoPreferenciasRequested()),
      child: BlocListener<SessionBloc, SessionState>(
        listener: (context, session) {
          if (!session.isAuthenticated &&
              ModalRoute.of(context)?.isCurrent == true) {
            Navigator.of(context).pop();
          }
        },
        child:
            BlocConsumer<CiudadanoPreferenciasBloc, CiudadanoPreferenciasState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == CiudadanoPreferenciasStatus.saved) {
                  context.read<CiudadanoCuentaBloc>().add(
                    const CiudadanoCuentaRequested(),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferencias guardadas.')),
                  );
                }
              },
              builder: (context, state) {
                final guardando =
                    state.status == CiudadanoPreferenciasStatus.saving;

                return PopScope(
                  canPop: !guardando,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('Preferencias de avisos'),
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        tooltip: 'Volver',
                        icon: const Icon(Icons.arrow_back),
                        onPressed: guardando
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    body: SafeArea(
                      child: CiudadanoPreferenciasContent(
                        state: state,
                        permiteAvisos:
                            perfil.aceptaTratamientoDatos &&
                            perfil.estadoCiudadano == 'ACTIVO',
                        versionConsentimiento: perfil.versionConsentimiento,
                        onConsultar: () {
                          context.read<CiudadanoPreferenciasBloc>().add(
                            const CiudadanoPreferenciasRequested(),
                          );
                        },
                        onGuardar: (request) {
                          context.read<CiudadanoPreferenciasBloc>().add(
                            CiudadanoPreferenciasSubmitted(request: request),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
