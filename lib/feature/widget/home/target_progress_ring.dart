part of '../../page/home.dart';

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
          height: 180,
          width: 180,
          child: CustomPaint(
            painter: _RingPainter(progress: clamped),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    percentageText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLimit ? 'Hedef' : 'Limit yok',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          limitText,
          style: context.textTheme.headlineSmall?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress; // 0.0 -> 1.2

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = const Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    final backgroundPaint = Paint()
      ..color = const Color(0xFFE8EDF4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, backgroundPaint);

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    const gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: (3 * math.pi) / 2,
      colors: const [
        Color(0xFF4CAF50),
        Color(0xFFFFC107),
        Color(0xFFF44336),
      ],
      stops: [0.0, 0.65, 1.0],
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
