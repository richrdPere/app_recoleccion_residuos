import 'package:flutter/material.dart';

class HomeOperacionItem extends StatelessWidget {
  final IconData icono;
  final String titulo;

  final VoidCallback? onTap;

  final double ancho;

  final Color colorIcono;
  final Color colorFondo;
  final Color colorTexto;

  const HomeOperacionItem({
    super.key,
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.ancho = 88,
    this.colorIcono = const Color(0xFF00AEEF),
    this.colorFondo = Colors.white,
    this.colorTexto = const Color(0xFF102A43),
  }) : assert(ancho >= 72);

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;

    return SizedBox(
      width: ancho,
      child: Semantics(
        label: titulo,
        button: true,
        enabled: habilitado,
        child: ExcludeSemantics(
          child: Tooltip(
            message: titulo,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withValues(alpha: 0.24),
                highlightColor: Colors.white.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Opacity(
                    opacity: habilitado ? 1 : 0.45,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // *********************************
                        // TARJETA DEL ICONO
                        // *********************************
                        Ink(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorFondo,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(icono, size: 31, color: colorIcono),
                        ),

                        const SizedBox(height: 10),

                        // *********************************
                        // NOMBRE DE LA OPERACIÓN
                        // *********************************
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 40),
                          child: Text(
                            titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorTexto,
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
