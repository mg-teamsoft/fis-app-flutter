import 'dart:math' as math;

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class WidgetPerChart extends StatelessWidget {
  /// double / 0.0 1.0
  final double value;

  /// Text in the middle of the widget
  final String label;
  final double size;
  final List<Color>? customColors;

  const WidgetPerChart({
    super.key,
    required this.value,
    required this.label,
    this.size = 200.0,
    this.customColors,
  }) : assert(value >= 0 && value <= 1, 'Value 0 ile 1 arasında olmalıdır.');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _MultiColorPainter(value: value, context: context),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '%${(value * 100).toInt()}',
                style: TextStyle(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ThemeTypography.h4(context, "HEDEF")
            ],
          ),
        ],
      ),
    );
  }
}

class _MultiColorPainter extends CustomPainter {
  final BuildContext context;
  final double value;

  _MultiColorPainter({required this.value, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    // Arka Plan (Gri halka)
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE8EDF4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * math.pi, false, backgroundPaint);

    if (value <= 0) return;

    final sweep = 2 * math.pi * value.clamp(0.0, 1.0);
    const startAngle = -math.pi / 2;

    final gradient = SweepGradient(
      colors: [
        context.theme.error,
        context.theme.warning,
        context.theme.info,
        context.theme.success,
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
      transform: const GradientRotation(startAngle),
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _MultiColorPainter oldDelegate) =>
      oldDelegate.value != value;
}
