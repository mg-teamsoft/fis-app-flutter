part of '../../page/home_page.dart';

class _TargetProgressRing extends StatefulWidget {
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
  State<_TargetProgressRing> createState() => _TargetProgressRingState();
}

class _TargetProgressRingState extends State<_TargetProgressRing> {
  late List<Color> _gradientColors;
  late double _clamped;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clamped = widget.progress.clamp(0.0, 1.2);
    _gradientColors = [
      context.theme.info,
      context.theme.success,
      context.theme.warning,
      context.theme.error,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: ThemeSize.avatarXXL,
          width: ThemeSize.avatarXXL,
          child: CustomPaint(
            painter: _RingPainter(
                outlineColor:
                    context.colorScheme.outline.withValues(alpha: 0.2),
                progress: _clamped,
                gradientColors: _gradientColors),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeTypography.h2(
                    context,
                    widget.percentageText,
                    weight: FontWeight.w800,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: ThemeSize.spacingXs),
                  ThemeTypography.bodyLarge(
                    context,
                    widget.hasLimit ? 'Hedef' : 'Limit yok',
                    weight: FontWeight.w600,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: ThemeSize.spacingM),
        ThemeTypography.h4(
          context,
          widget.limitText,
          weight: FontWeight.w800,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.outlineColor,
    required this.gradientColors,
    required this.progress,
  });

  final Color outlineColor;
  final List<Color> gradientColors;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const pi = math.pi;

    final backgroundPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress <= 0) return;

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);

    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: (3 * pi) / 2,
      colors: gradientColors,
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
    return oldDelegate.progress != progress ||
        oldDelegate.outlineColor != outlineColor;
  }
}
