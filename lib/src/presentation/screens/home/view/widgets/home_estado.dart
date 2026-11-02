import 'package:flutter/material.dart';

class HomeEstado extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String mensaje;

  final bool cargando;

  final String? textoAccion;
  final VoidCallback? onAccion;

  const HomeEstado({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.cargando = false,
    this.textoAccion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: cargando
                ? SizedBox.square(
                    dimension: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.primary,
                    ),
                  )
                : Icon(icono, size: 30, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (textoAccion != null && onAccion != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: cargando ? null : onAccion,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(textoAccion!),
            ),
          ],
        ],
      ),
    );
  }
}
