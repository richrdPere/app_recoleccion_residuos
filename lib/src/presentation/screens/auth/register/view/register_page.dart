import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Content
import 'register_content.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // *********************************************************
  // 1. LIMPIAR ESTADO AL ABRIR
  // *********************************************************

  @override
  void initState() {
    super.initState();

    context.read<RegisterBloc>().add(const RegisterReset());
  }

  // *********************************************************
  // 2. MOSTRAR ERROR
  // *********************************************************

  void _showError(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // *********************************************************
  // 3. CONFIRMACIÓN DEL REGISTRO
  // *********************************************************

  Future<void> _showSuccess(String message) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle_outline_rounded, size: 48),
          title: const Text('Cuenta creada'),
          content: Text(
            '$message\n\n'
            'Tu usuario y contraseña inicial son tu DNI.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Ir a iniciar sesión'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    context.go('/login');
  }

  // *********************************************************
  // 4. LISTENER Y CONTENIDO
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        if (state.isFailure) {
          _showError(state.message ?? 'No se pudo registrar la cuenta.');
          return;
        }

        if (state.isSuccess) {
          _showSuccess(
            state.message ?? 'Cuenta ciudadana registrada correctamente.',
          );
        }
      },

      child: const RegisterContent(),
    );
  }
}
