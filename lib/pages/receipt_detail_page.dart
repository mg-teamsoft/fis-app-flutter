import 'package:fis_app_flutter/models/receipt_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/receipt_api_service.dart';

class ReceiptDetailPage extends StatefulWidget {
  final String receiptId;
  const ReceiptDetailPage({super.key, required this.receiptId});

  @override
  State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  late Future<ReceiptDetail> _detail;
  final _currencyFormatter =
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  final _dateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');

  @override
  void initState() {
    super.initState();
    _detail = ReceiptApiService().getReceiptDetail(widget.receiptId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor:
          theme.colorScheme.surfaceContainerHighest.withOpacity(0.98),
      appBar: AppBar(
        title: const Text('Fiş Detayı'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
            tooltip: 'Düzenle',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
            tooltip: 'Paylaş',
          ),
        ],
      ),
      body: FutureBuilder<ReceiptDetail>(
        future: _detail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Fiş detayı yüklenirken bir hata oluştu.',
              onRetry: () {
                setState(() {
                  _detail =
                      ReceiptApiService().getReceiptDetail(widget.receiptId);
                });
              },
            );
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const _ErrorState(message: 'Fiş detayı bulunamadı.');
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ReceiptImage(imageUrl: detail.imageUrl),
              const SizedBox(height: 24),
              Text(
                detail.businessName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormatter.format(detail.totalAmount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                entries: [
                  _InfoRow(
                    label: 'Fiş No',
                    value: detail.receiptNumber,
                    secondaryLabel: 'İşlem Tarihi',
                    secondaryValue: detail.transactionDate != null
                        ? _dateFormatter.format(detail.transactionDate!)
                        : '—',
                  ),
                  _DividerRow(),
                  _InfoRow(
                    label: 'Toplam Tutar',
                    value: _currencyFormatter.format(detail.totalAmount),
                  ),
                  _InfoRow(
                    label: 'Toplam KDV Tutarı',
                    value: _currencyFormatter.format(detail.vatAmount),
                    secondaryLabel: 'KDV Oranı',
                    secondaryValue: '${detail.vatRate.toStringAsFixed(2)}%',
                  ),
                  _InfoRow(
                    label: 'İşlem Tipi',
                    value: detail.transactionType?.isNotEmpty == true
                        ? detail.transactionType!
                        : '—',
                  ),
                  _InfoRow(
                    label: 'Ödeme Tipi',
                    value: detail.paymentType?.isNotEmpty == true
                        ? detail.paymentType!
                        : '—',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReceiptImage extends StatelessWidget {
  const _ReceiptImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
              ),
            )
          : const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.entries});

  final List<Widget> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.secondaryLabel,
    this.secondaryValue,
  });

  final String label;
  final String value;
  final String? secondaryLabel;
  final String? secondaryValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (secondaryLabel != null && secondaryValue != null) ...[
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  secondaryLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  secondaryValue!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: theme.colorScheme.outlineVariant,
        height: 1,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
