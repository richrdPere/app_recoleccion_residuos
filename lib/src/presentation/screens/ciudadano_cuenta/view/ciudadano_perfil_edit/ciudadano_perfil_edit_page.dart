import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Content
import 'ciudadano_perfil_edit_content.dart';

class CiudadanoPerfilEditPage extends StatefulWidget {
  final int idCiudadano;

  const CiudadanoPerfilEditPage({super.key, required this.idCiudadano});

  @override
  State<CiudadanoPerfilEditPage> createState() =>
      _CiudadanoPerfilEditPageState();
}

class _CiudadanoPerfilEditPageState extends State<CiudadanoPerfilEditPage> {
  bool _saveRequested = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final state = context.read<CiudadanoCuentaBloc>().state;

      // Reutilizar el perfil verificado de Mi cuenta.
      if (state.status != CiudadanoCuentaStatus.ready ||
          state.perfil?.idCiudadano != widget.idCiudadano) {
        _consultar();
      }
    });
  }

  void _consultar() {
    context.read<CiudadanoCuentaBloc>().add(const CiudadanoCuentaRequested());
  }

  void _volver({bool actualizado = false}) {
    if (context.canPop()) {
      context.pop(actualizado);
    } else {
      context.go('/ciudadano/perfil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CiudadanoCuentaBloc, CiudadanoCuentaState>(
      listener: (context, state) {
        if (state.isFailure) {
          _saveRequested = false;
        }

        if (state.needsProfile) {
          _saveRequested = false;
          context.go('/ciudadano/acceso');
          return;
        }

        if (_saveRequested &&
            state.status == CiudadanoCuentaStatus.ready &&
            state.perfil?.idCiudadano == widget.idCiudadano) {
          _saveRequested = false;
          _volver(actualizado: true);
        }
      },
      builder: (context, state) {
        final perfil = state.perfil;
        final perfilCorrecto = perfil?.idCiudadano == widget.idCiudadano;

        return PopScope(
          canPop: !state.isBusy,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Editar perfil ciudadano'),
              automaticallyImplyLeading: false,
              leading: IconButton(
                tooltip: 'Volver',
                onPressed: state.isBusy ? null : () => _volver(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  if (perfil == null || !perfilCorrecto) {
                    if (state.isBusy ||
                        state.status == CiudadanoCuentaStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.errorMessage ??
                                  'El perfil solicitado no corresponde '
                                      'a la cuenta actual.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: _consultar,
                              child: const Text('Volver a consultar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return CiudadanoPerfilEditContent(
                    key: ValueKey(perfil.idCiudadano),
                    perfil: perfil,
                    isBusy: state.isBusy,
                    canSave: state.status == CiudadanoCuentaStatus.ready,
                    errorMessage: state.errorMessage,
                    onRetry: _consultar,
                    onCancel: () => _volver(),
                    onSave: (request) {
                      final current = context.read<CiudadanoCuentaBloc>().state;

                      if (current.status != CiudadanoCuentaStatus.ready ||
                          current.perfil?.idCiudadano != widget.idCiudadano) {
                        return;
                      }

                      FocusManager.instance.primaryFocus?.unfocus();

                      _saveRequested = true;

                      context.read<CiudadanoCuentaBloc>().add(
                        CiudadanoCuentaUpdateSubmitted(request: request),
                      );
                    },
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
