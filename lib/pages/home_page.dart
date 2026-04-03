import 'dart:math' as math;

import 'package:fis_app_flutter/core/theme/extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/services/home_service.dart';
import '../model/home_summary.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeService = HomeService();
  late Future<HomeSummary> _futureSummary;

  @override
  void initState() {
    super.initState();
    _futureSummary = _homeService.fetchSummary() as Future<HomeSummary>;
  }

  Future<void> _reload() async {
    setState(() {
      _futureSummary = _homeService.fetchSummary() as Future<HomeSummary>;
    });
    try {
      await _futureSummary;
    } catch (_) {
      // Swallow the error so the refresh animation can complete.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeSummary>(
      future: _futureSummary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _HomeError(
            details: snapshot.error?.toString(),
            onRetry: _reload,
          );
        }

        final summary = snapshot.data;
        if (summary == null) {
          return _HomeError(onRetry: _reload);
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            children: [
              _HomeHeader(summary: summary),
              const SizedBox(height: 20),
              _HomeActions(),
              const SizedBox(height: 28),
              _HomeRecentReceipts(summary: summary),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final totalSpentText = currencyFormatter.format(summary.totalSpent);
    final hasMonthlyLimit = summary.monthlyLimitAmount > 0;
    final usageFraction = hasMonthlyLimit && summary.monthlyLimitAmount > 0
        ? (summary.totalSpent / summary.monthlyLimitAmount).clamp(0.0, 1.2)
        : 0.0;
    final percentageText = hasMonthlyLimit
        ? '${(usageFraction * 100).clamp(0, 120).round()}%'
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.blue, size: 34),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Toplam Bakiye',
          style: TextStyle(fontSize: 17, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Text(
          totalSpentText,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        _TargetProgressRing(
          progress: usageFraction,
          percentageText: percentageText,
          hasLimit: hasMonthlyLimit,
          limitText: hasMonthlyLimit
              ? currencyFormatter.format(summary.monthlyLimitAmount)
              : 'Limit tanımlı değil',
        ),
      ],
    );
  }
}

class _TargetProgressRing extends StatelessWidget {
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
            painter: _RingPainter(progress: clamped.toDouble()),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    percentageText,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLimit ? 'Hedef' : 'Limit yok',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          limitText,
          style: TextStyle(color: Colors.grey.shade600),
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
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    final backgroundPaint = Paint()
      ..color = const Color(0xFFE8EDF4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, backgroundPaint);

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: (3 * math.pi) / 2,
      colors: const [
        Color(0xFF4CAF50),
        Color(0xFFFFC107),
        Color(0xFFF44336),
      ],
      stops: const [0.0, 0.65, 1.0],
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

class _HomeActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/receipt'),
            icon: const Icon(Icons.upload),
            label: const Text('Fiş Yükle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/excelFiles'),
            icon: const Icon(Icons.table_chart),
            label: const Text('Excel Görüntüle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeRecentReceipts extends StatelessWidget {
  const _HomeRecentReceipts({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');

    final receipts = summary.recentReceipts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Son Fişler',
            style: context.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        if (receipts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(
              'Aylık işleminiz bulunmuyor.',
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          ...receipts.map((receipt) {
            final date = receipt.transactionDate;
            final dateText =
                date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
            final amountText = currencyFormatter.format(receipt.totalAmount);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _InvoiceItem(
                title: receipt.businessName,
                date: dateText,
                amount: amountText,
              ),
            );
          }),
      ],
    );
  }
}

class _InvoiceItem extends StatelessWidget {
  const _InvoiceItem({
    required this.title,
    required this.date,
    required this.amount,
  });

  final String title;
  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        date,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: theme.colorScheme.surface,
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({this.details, required this.onRetry});

  final String? details;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Veriler alınırken bir hata oluştu.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
