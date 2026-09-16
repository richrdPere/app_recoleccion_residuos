
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Content
import 'loading_content.dart';


class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final LoadingBloc _loadingBloc;

  @override
  void initState() {
    super.initState();

    _loadingBloc = LoadingBloc(sessionBloc: context.read<SessionBloc>());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadingBloc.add(const LoadingStarted());
    });
  }

  @override
  void dispose() {
    _loadingBloc.close();
    super.dispose();
  }

  void _returnAfterError() {
    final sessionStatus = context.read<SessionBloc>().state.status;

    // Si falló la restauración, el splash permite reintentarla.
    if (sessionStatus == SessionStatus.initial) {
      context.go('/splash');
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _loadingBloc,
      child: BlocConsumer<LoadingBloc, LoadingState>(
        listener: (context, state) {
          if (state.status == LoadingStatus.authenticated) {
            context.go('/home');
          } else if (state.status == LoadingStatus.unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: false,
            child: LoadingContent(state: state, onReturn: _returnAfterError),
          );
        },
      ),
    );
  }
}
