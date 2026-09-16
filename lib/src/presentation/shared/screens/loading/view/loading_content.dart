import 'package:flutter/material.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class LoadingContent extends StatelessWidget {
  final LoadingState state;
  final VoidCallback onReturn;

  const LoadingContent({
    super.key,
    required this.state,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final hasError = state.status == LoadingStatus.failure;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: hasError
                                  ? colors.errorContainer
                                  : colors.primaryContainer,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              hasError
                                  ? Icons.error_outline_rounded
                                  : Icons.local_shipping_rounded,
                              size: 52,
                              color: hasError
                                  ? colors.onErrorContainer
                                  : colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 28),

                          Text(
                            hasError
                                ? 'No se pudo completar el acceso'
                                : 'Un momento',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            hasError
                                ? (state.errorMessage ??
                                      'Ocurrió un error al preparar la sesión.')
                                : state.message,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),

                          if (hasError)
                            FilledButton.icon(
                              onPressed: onReturn,
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Volver'),
                            )
                          else
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                semanticsLabel: 'Preparando sesión',
                              ),
                            ),
                        ],
                      ),
                    ),
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
