import 'package:flutter/material.dart';

class CiudadanoOperacionItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback? onTap;

  final Color? colorTexto;
  final Color? colorIcono;
  final Color? colorFondoIcono;

  const CiudadanoOperacionItem({
    super.key,
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.colorTexto,
    this.colorIcono,
    this.colorFondoIcono,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final habilitado = onTap != null;

    final texto = colorTexto ?? colors.onSurface;
    final contenidoIcono = colorIcono ?? colors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorFondoIcono ?? colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icono,
                  size: 30,
                  color: habilitado
                      ? contenidoIcono
                      : contenidoIcono.withValues(alpha: 0.38),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                titulo,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: habilitado ? texto : texto.withValues(alpha: 0.50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
