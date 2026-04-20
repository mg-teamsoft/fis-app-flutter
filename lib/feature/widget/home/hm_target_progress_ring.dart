part of '../../page/home_page.dart';

final class _TargetProgressRing extends StatelessWidget {
  const _TargetProgressRing({
    required this.progress,
    required this.percentageText,
    required this.hasLimit,
    required this.limitText,
  });

  final double progress; // 0.0 -> 1.2 (slight overflow allowed)
  final String percentageText;
  final bool hasLimit;
  final String limitText;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.2);
    return Column(
      children: [
        SizedBox(
          height: ThemeSize.avatarXXL,
          width: ThemeSize.avatarXXL,
          child: CustomPaint(
            painter: _RingPainter(context: context, progress: clamped),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeTypography.h2(
                    context,
                    percentageText,
                    weight: FontWeight.w800,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: ThemeSize.spacingXs),
                  ThemeTypography.bodyMedium(
                    context,
                    hasLimit ? 'Hedef' : 'Limit yok',
                    weight: FontWeight.w600,
                    color: context.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: ThemeSize.spacingM),
        ThemeTypography.h2(
          context,
          limitText,
          weight: FontWeight.w800,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.context, required this.progress});

  final BuildContext context;
  final double progress; // 0.0 -> 1.2

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = const Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    const pi = math.pi;

    final backgroundPaint = Paint()
      ..color = context.colorScheme.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, backgroundPaint);

    if (progress <= 0) return;
    final sweep = 2 * pi * progress.clamp(0.0, 1.0);

    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: (3 * pi) / 2,
      colors: [
        context.theme.info,
        context.theme.success,
        context.theme.warning,
        context.theme.error,
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, sweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
