import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'ciudadano_perfil_form_content.dart';

class CiudadanoAccesoPage extends StatefulWidget {
  const CiudadanoAccesoPage({super.key});

  @override
  State<CiudadanoAccesoPage> createState() => _CiudadanoAccesoPageState();
}

class _CiudadanoAccesoPageState extends State<CiudadanoAccesoPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _consultarPerfil();
    });
  }

  // *********************************************************
  // 1. CONSULTAR PERFIL
  // *********************************************************

  void _consultarPerfil() {
    context.read<CiudadanoCuentaBloc>().add(const CiudadanoCuentaRequested());
  }

  // *********************************************************
  // 2. MENSAJES
  // *********************************************************

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // *********************************************************
  // 3. INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CiudadanoCuentaBloc, CiudadanoCuentaState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        if (state.status == CiudadanoCuentaStatus.ready && state.hasProfile) {
          FocusManager.instance.primaryFocus?.unfocus();

          final message = state.successMessage;

          if (message != null && message.isNotEmpty) {
            _showMessage(message);
          }

          context.go('/ciudadano/inicio');
        }
      },
      builder: (context, state) {
        final isSaving = state.isCreating || state.isUpdating;

        return PopScope(
          canPop: !state.isBusy,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Perfil ciudadano'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  tooltip: 'Cerrar sesión',
                  onPressed: state.isBusy
                      ? null
                      : () {
                          context.read<SessionBloc>().add(
                            const SessionLogoutRequested(),
                          );
                        },
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  // CONSULTA INICIAL
                  if (state.status == CiudadanoCuentaStatus.initial ||
                      state.isLoading) {
                    return const _PerfilProgress(
                      message: 'Verificando tu perfil ciudadano…',
                    );
                  }

                  // PERFIL INEXISTENTE / CREACIÓN
                  if (state.needsProfile || isSaving) {
                    return CiudadanoPerfilFormContent(
                      isSaving: isSaving,
                      onSubmit: (request) {
                        context.read<CiudadanoCuentaBloc>().add(
                          CiudadanoCuentaCreateSubmitted(request: request),
                        );
                      },
                    );
                  }

                  // ERROR: NO ASUMIR QUE FALTA EL PERFIL
                  if (state.isFailure) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 52,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.errorMessage ??
                                    'No se pudo consultar tu perfil.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: _consultarPerfil,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Volver a consultar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Esperar la navegación del listener.
                  return const _PerfilProgress(
                    message: 'Abriendo el área ciudadana…',
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PerfilProgress extends StatelessWidget {
  final String message;

  const _PerfilProgress({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
