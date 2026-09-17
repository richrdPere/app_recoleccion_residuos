import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Content
import 'perfil_content.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _logoutDialogOpen = false;

  // *********************************************************
  // 1. CONSULTAR PERFIL
  // *********************************************************
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PerfilBloc>().add(const PerfilRequested());
    });
  }

  // *********************************************************
  // 2. ACTUALIZAR PERFIL
  // *********************************************************
  Future<void> _refresh() async {
    final bloc = context.read<PerfilBloc>();

    if (bloc.isClosed) return;

    // Suscribirse antes de enviar el evento para esperar
    // el resultado real de la consulta.
    final completion = bloc.stream.firstWhere(
      (state) =>
          state.status == PerfilStatus.success ||
          state.status == PerfilStatus.failure,
    );

    if (!bloc.state.isBusy) {
      bloc.add(const PerfilRequested());
    }

    try {
      await completion;
    } on StateError {
      // El BLoC pudo cerrarse al desmontar la aplicación.
    }
  }

  // *********************************************************
  // 3. CONFIRMAR CIERRE DE SESIÓN
  // *********************************************************
  Future<void> _confirmLogout() async {
    if (_logoutDialogOpen) return;

    _logoutDialogOpen = true;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text(
              '¿Deseas cerrar tu sesión en este dispositivo?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmed != true) return;

      // LogoutPage inicia el cierre mediante LogoutBloc.
      context.go('/logout');
    } finally {
      _logoutDialogOpen = false;
    }
  }

  // *********************************************************
  // 4. INTERFAZ Y MENSAJES
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PerfilBloc, PerfilState>(
      listener: (context, state) {
        // Si ya hay datos, mantenerlos visibles y mostrar
        // el error de actualización mediante un mensaje.
        if (state.hasError && state.hasData) {
          final messenger = ScaffoldMessenger.of(context);

          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'No se pudo actualizar tu perfil.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return PerfilContent(
          state: state,
          onRefresh: _refresh,
          onLogout: _confirmLogout,
        );
      },
    );
  }
}
