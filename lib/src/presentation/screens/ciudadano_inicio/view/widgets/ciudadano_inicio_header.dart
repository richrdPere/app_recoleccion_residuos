import 'package:flutter/material.dart';

class CiudadanoInicioHeader extends StatelessWidget {
  final String nombre;
  final Widget campana;

  const CiudadanoInicioHeader({
    super.key,
    required this.nombre,
    required this.campana,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final nombreVisible = nombre.trim().isEmpty ? 'Ciudadano' : nombre.trim();

    return Material(
      color: colors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: colors.onPrimary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _saludo(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nombreVisible,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: IconTheme(
                  data: IconThemeData(color: colors.primary, size: 26),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: campana),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _saludo() {
    final hora = DateTime.now().hour;

    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';

    return 'Buenas noches';
  }
}
