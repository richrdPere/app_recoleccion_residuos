import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Content
import 'package:app_recoleccion_residuos/src/presentation/shared/screens/splash/view/splash_content.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashBloc _splashBloc;

  @override
  void initState() {
    super.initState();

    _splashBloc = SplashBloc(sessionBloc: context.read<SessionBloc>());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _splashBloc.add(const SplashStarted());
    });
  }

  @override
  void dispose() {
    // BlocProvider.value no cierra esta instancia.
    _splashBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _splashBloc,
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          switch (state.status) {
            case SplashStatus.authenticated:
              context.go('/home');
              return;

            case SplashStatus.unauthenticated:
              context.go('/login');
              return;

            case SplashStatus.loading:
            case SplashStatus.failure:
              return;
          }
        },
        builder: (context, state) {
          return SplashContent(
            state: state,
            onRetry: () {
              _splashBloc.add(const SplashRetryRequested());
            },
          );
        },
      ),
    );
  }
}
