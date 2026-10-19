import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'ciudadano_cuenta_content.dart';

class CiudadanoCuentaPage extends StatefulWidget {
  const CiudadanoCuentaPage({super.key});

  @override
  State<CiudadanoCuentaPage> createState() => _CiudadanoCuentaPageState();
}

class _CiudadanoCuentaPageState extends State<CiudadanoCuentaPage> {
  bool _logoutDialogOpen = false;
  bool _editPageOpen = false;
  bool _domiciliosPageOpen = false;

  // *********************************************************
  // 1. CONSULTAR AL ABRIR
  // *********************************************************

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadProfile();
    });
  }

  void _loadProfile() {
    context.read<CiudadanoCuentaBloc>().add(const CiudadanoCuentaRequested());
  }

  // *********************************************************
  // 2. MOSTRAR MENSAJES
  // *********************************************************

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // *********************************************************
  // 3. CONFIRMAR CIERRE DE SESIÓN
  // *********************************************************

  Future<void> _confirmLogout() async {
    if (_logoutDialogOpen || _editPageOpen) return;

    final cuenta = context.read<CiudadanoCuentaBloc>().state;
    final session = context.read<SessionBloc>().state;

    if (cuenta.isBusy || !session.isAuthenticated) return;

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

      if (!context.read<SessionBloc>().state.isAuthenticated) {
        return;
      }

      // LogoutPage inicia el cierre mediante LogoutBloc.
      context.go('/logout');
    } finally {
      _logoutDialogOpen = false;
    }
  }

  // *********************************************************
  // 4. EDITAR PERFIL CIUDADANO
  // *********************************************************

  Future<void> _editProfile() async {
    if (_editPageOpen || _logoutDialogOpen) return;

    final cuenta = context.read<CiudadanoCuentaBloc>().state;
    final session = context.read<SessionBloc>().state;
    final perfil = cuenta.perfil;

    if (!session.isAuthenticated ||
        cuenta.status != CiudadanoCuentaStatus.ready ||
        perfil == null) {
      return;
    }

    _editPageOpen = true;

    try {
      final updated = await context.pushNamed<bool>(
        'ciudadano-perfil-editar',
        pathParameters: {'idCiudadano': perfil.idCiudadano.toString()},
      );

      if (!mounted || updated != true) return;

      // El BLoC ya recargó el perfil antes de cerrar la edición.
      final current = context.read<CiudadanoCuentaBloc>().state;

      if (current.status == CiudadanoCuentaStatus.ready &&
          current.perfil?.idCiudadano == perfil.idCiudadano) {
        _showMessage(
          current.successMessage ??
              'Perfil ciudadano actualizado correctamente.',
        );
      }
    } finally {
      _editPageOpen = false;
    }
  }

  // *********************************************************
  // 5. ABRIR MIS DOMICILIOS
  // *********************************************************

  Future<void> _openDomicilios() async {
    if (_domiciliosPageOpen || _editPageOpen || _logoutDialogOpen) {
      return;
    }

    final cuenta = context.read<CiudadanoCuentaBloc>().state;
    final session = context.read<SessionBloc>().state;

    if (!session.isAuthenticated || cuenta.isBusy || cuenta.perfil == null) {
      return;
    }

    _domiciliosPageOpen = true;

    try {
      await context.pushNamed('ciudadano-domicilios');
    } finally {
      _domiciliosPageOpen = false;
    }
  }

  // *********************************************************
  // 5. LISTENER Y CONTENIDO
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select(
      (SessionBloc bloc) => bloc.state.isAuthenticated,
    );

    return BlocConsumer<CiudadanoCuentaBloc, CiudadanoCuentaState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.successMessage != current.successMessage;
      },
      listener: (context, state) {
        // La pantalla de edición administra sus propios resultados.
        if (_editPageOpen) return;

        if (state.needsProfile) {
          context.go('/ciudadano/acceso');
          return;
        }

        final message = state.successMessage;

        if (state.status == CiudadanoCuentaStatus.ready &&
            message != null &&
            message.isNotEmpty) {
          _showMessage(message);
        }
      },
      builder: (context, state) {
        return CiudadanoCuentaContent(
          state: state,
          onRefresh: _loadProfile,
          onLogout: _confirmLogout,
          canLogout: isAuthenticated && !state.isBusy,
          onEdit: _editProfile,
          onOpenDomicilios: _openDomicilios,
        );
      },
    );
  }
}
