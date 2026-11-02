import 'package:flutter/material.dart';

class MapaAccionBoton extends StatelessWidget {
  final IconData icono;
  final String tooltip;

  final VoidCallback? onPressed;

  final bool cargando;

  final Color? colorFondo;
  final Color? colorIcono;

  final double tamanio;

  const MapaAccionBoton({
    super.key,
    required this.icono,
    required this.tooltip,
    required this.onPressed,
    this.cargando = false,
    this.colorFondo,
    this.colorIcono,
    this.tamanio = 52,
  }) : assert(tamanio >= 48);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final habilitado = onPressed != null && !cargando;

    final fondo = colorFondo ?? colors.surface;

    final primerPlano = colorIcono ?? colors.onSurface;

    final colorVisible = habilitado || cargando
        ? primerPlano
        : primerPlano.withValues(alpha: 0.40);

    return Semantics(
      button: true,
      enabled: habilitado,
      label: cargando ? '$tooltip. En proceso' : tooltip,
      child: Tooltip(
        message: cargando ? '$tooltip…' : tooltip,
        excludeFromSemantics: true,
        child: Material(
          color: fondo,
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: habilitado ? onPressed : null,
            canRequestFocus: habilitado,
            child: SizedBox.square(
              dimension: tamanio,
              child: Center(
                child: cargando
                    ? SizedBox.square(
                        dimension: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primerPlano,
                        ),
                      )
                    : Icon(icono, size: 26, color: colorVisible),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
