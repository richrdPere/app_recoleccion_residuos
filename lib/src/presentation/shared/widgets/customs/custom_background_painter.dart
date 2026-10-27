// ==========================================================
// FONDO IRREGULAR DEL HOME
// ==========================================================

import 'package:flutter/material.dart';

class CustomBackgroundPainter extends CustomPainter {
  final ColorScheme colorScheme;
  final bool isDark;

  const CustomBackgroundPainter({
    required this.colorScheme,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawTopShape(canvas, size);
    _drawMiddleShape(canvas, size);
    _drawBottomShape(canvas, size);
    _drawDecorativeCircles(canvas, size);
  }

  // ========================================================
  // FORMA SUPERIOR
  // ========================================================

  void _drawTopShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.10)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.20)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.15,
        size.width * 0.62,
        size.height * 0.28,
        size.width * 0.40,
        size.height * 0.21,
      )
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.15,
        size.width * 0.12,
        size.height * 0.25,
        0,
        size.height * 0.19,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  // ========================================================
  // FORMA CENTRAL
  // ========================================================

  void _drawMiddleShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: isDark ? 0.10 : 0.065)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, size.height * 0.38)
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.32,
        size.width * 0.69,
        size.height * 0.45,
        size.width * 0.58,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.60,
        size.width * 0.90,
        size.height * 0.53,
        size.width,
        size.height * 0.58,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  // ========================================================
  // FORMA INFERIOR
  // ========================================================

  void _drawBottomShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.tertiary.withValues(alpha: isDark ? 0.12 : 0.07)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.72,
        size.width * 0.32,
        size.height * 0.82,
        size.width * 0.46,
        size.height * 0.87,
      )
      ..cubicTo(
        size.width * 0.63,
        size.height * 0.94,
        size.width * 0.82,
        size.height * 0.84,
        size.width,
        size.height * 0.91,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  // ========================================================
  // CÍRCULOS DECORATIVOS
  // ========================================================

  void _drawDecorativeCircles(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.055)
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: isDark ? 0.09 : 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.89, size.height * 0.12),
      46,
      primaryPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.48),
      30,
      secondaryPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.72),
      22,
      primaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomBackgroundPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.isDark != isDark;
  }
}
