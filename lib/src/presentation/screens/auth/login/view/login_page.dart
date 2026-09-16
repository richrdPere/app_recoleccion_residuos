
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'login_content.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _showError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // *********************************************************
        // 1. RESULTADO DEL LOGIN REMOTO
        // *********************************************************
        BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.failure) {
              _showError(
                context,
                state.errorMessage ?? 'No se pudo iniciar sesión.',
              );
              return;
            }

            if (state.status == LoginStatus.success) {
              final loginData = state.loginData;

              if (loginData == null) return;

              context.read<SessionBloc>().add(
                SessionEstablished(loginData: loginData),
              );
            }
          },
        ),

        // *********************************************************
        // 2. RESULTADO DE GUARDAR O RESTAURAR LA SESIÓN
        // *********************************************************
        BlocListener<SessionBloc, SessionState>(
          listener: (context, state) {
            final errorMessage = state.errorMessage;

            if (errorMessage != null && errorMessage.isNotEmpty) {
              _showError(context, errorMessage);
            }

            if (state.status == SessionStatus.authenticated) {
              FocusManager.instance.primaryFocus?.unfocus();

              context.go('/home');
            }
          },
        ),
      ],
      child: const LoginContent(),
    );
  }
}
