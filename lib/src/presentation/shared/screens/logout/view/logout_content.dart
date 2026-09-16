import 'package:flutter/material.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class LogoutContent extends StatelessWidget {
  final LogoutState state;
  final VoidCallback onRetry;
  final VoidCallback onReturn;

  const LogoutContent({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final hasError = state.status == LogoutStatus.failure;

    final String returnLabel;

    switch (state.returnRoute) {
      case '/login':
        returnLabel = 'Ir al login';
        break;

      case '/splash':
        returnLabel = 'Volver al inicio de la aplicación';
        break;

      default:
        returnLabel = 'Volver al inicio';
    }

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
                          // *********************************
                          // ICONO
                          // *********************************
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
                                  : Icons.logout_rounded,
                              size: 52,
                              color: hasError
                                  ? colors.onErrorContainer
                                  : colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // *********************************
                          // TÍTULO Y MENSAJE
                          // *********************************
                          Text(
                            hasError
                                ? 'No se completó el cierre'
                                : 'Cerrando sesión',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            hasError
                                ? (state.errorMessage ??
                                      'Ocurrió un error al cerrar sesión.')
                                : 'Espera un momento mientras finalizamos '
                                      'tu sesión.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // *********************************
                          // ACCIONES O PROGRESO
                          // *********************************
                          if (hasError) ...[
                            if (state.canRetry) ...[
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: onRetry,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reintentar'),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            TextButton(
                              onPressed: onReturn,
                              child: Text(
                                returnLabel,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                semanticsLabel: 'Cerrando sesión',
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
