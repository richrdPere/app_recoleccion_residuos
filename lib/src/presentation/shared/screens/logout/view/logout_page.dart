
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Content
import 'logout_content.dart';


class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  late final LogoutBloc _logoutBloc;

  @override
  void initState() {
    super.initState();

    _logoutBloc = LogoutBloc(
      sessionBloc: context.read<SessionBloc>(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _logoutBloc.add(const LogoutStarted());
    });
  }

  @override
  void dispose() {
    _logoutBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _logoutBloc,
      child: BlocConsumer<LogoutBloc, LogoutState>(
        listener: (context, state) {
          if (state.status == LogoutStatus.success) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: false,
            child: LogoutContent(
              state: state,
              onRetry: () {
                _logoutBloc.add(const LogoutRetryRequested());
              },
              onReturn: () {
                context.go(state.returnRoute);
              },
            ),
          );
        },
      ),
    );
  }
}