import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppGeometricalBackground extends StatelessWidget {
  final Widget child;

  /// Cantidad de figuras por fila.
  final int columns;

  /// Porción de la altura cubierta por el patrón.
  /// 0.7 = 70 %, 1 = toda la superficie.
  final double patternHeightFactor;

  /// Permite obtener distintas distribuciones de figuras.
  /// La misma semilla mantiene el mismo patrón.
  final int seed;

  final Color? backgroundColor;
  final Color? patternBackgroundColor;
  final Color? shapeColor;

  final EdgeInsetsGeometry padding;

  const AppGeometricalBackground({
    super.key,
    required this.child,
    this.columns = 7,
    this.patternHeightFactor = 0.7,
    this.seed = 15,
    this.backgroundColor,
    this.patternBackgroundColor,
    this.shapeColor,
    this.padding = EdgeInsets.zero,
  }) : assert(columns > 0),
       assert(patternHeightFactor >= 0 && patternHeightFactor <= 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final effectiveBackground =
        backgroundColor ?? theme.scaffoldBackgroundColor;

    final effectivePatternBackground =
        patternBackgroundColor ?? colors.surfaceContainerLow;

    final effectiveShapeColor =
        shapeColor ?? colors.primary.withValues(alpha: 0.08);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ==================================================
          // COLOR BASE
          // ==================================================
          ColoredBox(color: effectiveBackground),

          // ==================================================
          // PATRÓN DECORATIVO
          // ==================================================
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: patternHeightFactor,
                    child: ClipRect(
                      child: ColoredBox(
                        color: effectivePatternBackground,
                        child: CustomPaint(
                          painter: _GeometricalPatternPainter(
                            columns: columns,
                            seed: seed,
                            color: effectiveShapeColor,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==================================================
          // CONTENIDO
          // ==================================================
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

// ==========================================================
// FIGURAS DISPONIBLES
// ==========================================================

enum _GeometricalShape {
  circle,
  square,
  rightTriangle,
  leftTriangle,
  diamond,
  semicircle,
  invertedSemicircle,
}

// ==========================================================
// PINTOR DEL PATRÓN
// ==========================================================

class _GeometricalPatternPainter extends CustomPainter {
  final int columns;
  final int seed;
  final Color color;

  const _GeometricalPatternPainter({
    required this.columns,
    required this.seed,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final cellSize = size.width / columns;
    final rows = (size.height / cellSize).ceil();

    final random = math.Random(seed);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (var row = 0; row < rows; row++) {
      // Con 7 columnas, cada fila incluye las 7 figuras.
      final shapes = List<_GeometricalShape>.generate(
        columns,
        (index) =>
            _GeometricalShape.values[index % _GeometricalShape.values.length],
      )..shuffle(random);

      for (var column = 0; column < columns; column++) {
        canvas.save();

        canvas.translate(column * cellSize, row * cellSize);

        _drawShape(canvas, Size.square(cellSize), paint, shapes[column]);

        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _drawShape(
    Canvas canvas,
    Size size,
    Paint paint,
    _GeometricalShape shape,
  ) {
    final rect = Offset.zero & size;

    switch (shape) {
      case _GeometricalShape.circle:
        canvas.drawCircle(rect.center, size.width / 2, paint);
        break;

      case _GeometricalShape.square:
        canvas.drawRect(rect, paint);
        break;

      case _GeometricalShape.rightTriangle:
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(0, size.height)
          ..close();

        canvas.drawPath(path, paint);
        break;

      case _GeometricalShape.leftTriangle:
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..close();

        canvas.drawPath(path, paint);
        break;

      case _GeometricalShape.diamond:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width, size.height / 2)
          ..close();

        canvas.drawPath(path, paint);
        break;

      case _GeometricalShape.semicircle:
        canvas.drawArc(rect, math.pi, math.pi, false, paint);
        break;

      case _GeometricalShape.invertedSemicircle:
        canvas.drawArc(rect, math.pi, -math.pi, false, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricalPatternPainter oldDelegate) {
    return oldDelegate.columns != columns ||
        oldDelegate.seed != seed ||
        oldDelegate.color != color;
  }
}
