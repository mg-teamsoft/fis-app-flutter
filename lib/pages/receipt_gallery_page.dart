import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/receipt_summary.dart';
import '../services/receipt_api_service.dart';
import 'receipt_detail_page.dart';

// ignore_for_file: prefer_const_constructors
class ReceiptGalleryPage extends StatefulWidget {
  const ReceiptGalleryPage({super.key});

  @override
  State<ReceiptGalleryPage> createState() => _ReceiptGalleryPageState();
}

class _ReceiptGalleryPageState extends State<ReceiptGalleryPage> {
  final _receiptApiService = ReceiptApiService();
  late Future<List<ReceiptSummary>> _futureReceipts;

  @override
  void initState() {
    super.initState();
    _futureReceipts = _receiptApiService.listReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ReceiptSummary>>(
        future: _futureReceipts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _GalleryError(
              message: 'Fişler yüklenirken bir hata oluştu.',
              details: snapshot.error?.toString(),
              onRetry: () {
                setState(() {
                  _futureReceipts = _receiptApiService.listReceipts();
                });
              },
            );
          }

          final receipts = snapshot.data ?? const <ReceiptSummary>[];
          if (receipts.isEmpty) {
            return const _GalleryEmptyState();
          }

          return _ReceiptsList(
            receipts: receipts,
            onOpenDetails: _openDetails,
          );
        },
      ),
    );
  }

  void _openDetails(ReceiptSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailPage(receiptId: summary.id),
      ),
    );
  }
}

class _ReceiptsList extends StatelessWidget {
  const _ReceiptsList({
    required this.receipts,
    required this.onOpenDetails,
  });

  final List<ReceiptSummary> receipts;
  final void Function(ReceiptSummary) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');
    final monthFormatter = DateFormat('MMMM yyyy', 'tr_TR');
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    final Map<DateTime?, List<ReceiptSummary>> grouped = {};
    for (final receipt in receipts) {
      final date = receipt.transactionDate;
      final key = (date == null)
          ? null
          : DateTime(date.year, date.month); // normalize to month
      grouped.putIfAbsent(key, () => []).add(receipt);
    }

    final List<_ReceiptMonthGroup> groups = grouped.entries.map((entry) {
      final items = [...entry.value]..sort((a, b) {
          final aDate =
              a.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              b.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      final label = entry.key != null
          ? _capitalize(monthFormatter.format(entry.key!))
          : 'Tarihsiz';
      return _ReceiptMonthGroup(label: label, items: items, sortKey: entry.key);
    }).toList()
      ..sort((a, b) {
        if (a.sortKey == null && b.sortKey == null) return 0;
        if (a.sortKey == null) return 1;
        if (b.sortKey == null) return -1;
        return b.sortKey!.compareTo(a.sortKey!);
      });

    final List<Widget> children = [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(
          'Fişler',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];

    for (final group in groups) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            group.label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      for (final receipt in group.items) {
        final date = receipt.transactionDate;
        final dateText =
            date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _ReceiptListTile(
              summary: receipt,
              dateText: dateText,
              amountText: currencyFormatter.format(receipt.totalAmount),
              onOpenDetails: onOpenDetails,
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

class _ReceiptMonthGroup {
  _ReceiptMonthGroup({
    required this.label,
    required this.items,
    required this.sortKey,
  });

  final String label;
  final List<ReceiptSummary> items;
  final DateTime? sortKey;
}

class _ReceiptListTile extends StatelessWidget {
  const _ReceiptListTile({
    required this.summary,
    required this.dateText,
    required this.amountText,
    required this.onOpenDetails,
  });

  final ReceiptSummary summary;
  final String dateText;
  final String amountText;
  final void Function(ReceiptSummary) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () => onOpenDetails(summary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tileColor: theme.colorScheme.surface,
      leading: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
      title: Text(
        summary.businessName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        dateText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        amountText,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long,
                size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Henüz kayıtlı fiş bulunmuyor.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryError extends StatelessWidget {
  const _GalleryError({
    required this.message,
    this.details,
    required this.onRetry,
  });

  final String message;
  final String? details;
  final VoidCallback onRetry;

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
              message,
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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
