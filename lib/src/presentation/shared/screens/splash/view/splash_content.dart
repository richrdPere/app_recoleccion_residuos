import 'package:flutter/material.dart';

// State
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class SplashContent extends StatelessWidget {
  final SplashState state;
  final VoidCallback onRetry;

  const SplashContent({super.key, required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final hasError = state.status == SplashStatus.failure;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // *********************************
                          // IDENTIDAD
                          // *********************************
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Icon(
                              Icons.local_shipping_rounded,
                              size: 60,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 28),

                          Text(
                            'Recolección de residuos',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            'Municipalidad Provincial de Calca',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 44),

                          // *********************************
                          // CARGA O ERROR
                          // *********************************
                          if (hasError) ...[
                            Icon(
                              Icons.error_outline_rounded,
                              size: 32,
                              color: colors.error,
                            ),
                            const SizedBox(height: 12),

                            Text(
                              state.errorMessage ??
                                  'No se pudo recuperar la sesión.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),

                            FilledButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reintentar'),
                            ),
                          ] else ...[
                            const SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                semanticsLabel: 'Preparando sesión',
                              ),
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'Preparando tu sesión…',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
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
