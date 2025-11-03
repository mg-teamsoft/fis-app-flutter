import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/home_summary.dart';
import '../services/home_service.dart';

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
    _futureSummary = _homeService.fetchSummary();
  }

  Future<void> _reload() async {
    setState(() {
      _futureSummary = _homeService.fetchSummary();
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
    final monthlyLimitText = hasMonthlyLimit
        ? currencyFormatter.format(summary.monthlyLimitAmount)
        : '—';
    final percentageText = _buildPercentageText(summary, hasMonthlyLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Toplam Tutar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                totalSpentText,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SummaryRow(title: 'Aylık Limit', value: monthlyLimitText),
        const SizedBox(height: 8),
        _SummaryRow(
          title: 'Kullanım',
          value:
              summary.limitUsageText.isNotEmpty ? summary.limitUsageText : '—',
        ),
        const SizedBox(height: 8),
        _SummaryRow(title: 'Oran %', value: percentageText),
      ],
    );
  }

  String _buildPercentageText(HomeSummary summary, bool hasMonthlyLimit) {
    if (!hasMonthlyLimit) return '—';
    if (summary.monthlyLimitAmount == 0) return '—';
    final raw = (summary.totalSpent / summary.monthlyLimitAmount) * 100;
    if (!raw.isFinite) return '—';
    final roundedUp = raw.ceil();
    return '$roundedUp%';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son Fişler',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
