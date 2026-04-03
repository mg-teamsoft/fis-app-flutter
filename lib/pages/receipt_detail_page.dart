import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/model/receipt_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/services/receipt_api_service.dart';

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
    //_detail = ReceiptApiService().getReceiptDetail(widget.receiptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primary.withValues(alpha: 0.98),
      appBar: AppBar(
        title: ThemeTypography.h4(
          context,
          'Fiş Detayı',
        ),
        backgroundColor: context.colorScheme.primary.withValues(alpha: 0.2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: context.colorScheme.onPrimary,
            iconSize: ThemeSize.iconMedium,
            onPressed: () {},
            tooltip: 'Düzenle',
          ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: context.colorScheme.onPrimary,
              size: ThemeSize.iconMedium,
            ),
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
                  //_detail =
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
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormatter.format(detail.totalAmount),
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.colorScheme.onPrimary,
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

class _ReceiptImage extends StatefulWidget {
  const _ReceiptImage({required this.imageUrl});

  final String imageUrl;

  @override
  State<_ReceiptImage> createState() => _ReceiptImageState();
}

class _ReceiptImageState extends State<_ReceiptImage> {
  int _rotationQuarterTurns = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.25,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.imageUrl.isNotEmpty
          ? Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: RotatedBox(
                        quarterTurns: _rotationQuarterTurns,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (_, error, __) {
                            debugPrint(
                              'Receipt image load failed. url=${widget.imageUrl} error=$error',
                            );
                            return const _ImagePlaceholder();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: context.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.8),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon: Icon(Icons.rotate_right,
                          color: context.colorScheme.onSurface),
                      onPressed: () {
                        setState(() {
                          _rotationQuarterTurns =
                              (_rotationQuarterTurns + 1) % 4;
                        });
                      },
                      tooltip: 'Döndür',
                    ),
                  ),
                ),
              ],
            )
          : const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      color: context.colorScheme.surfaceContainerHighest,
      child: Column(children: [
        SizedBox(
          height: size.height * 0.1,
        ),
        Icon(
          Icons.image_not_supported_outlined,
          size: ThemeSize.avatarLarge,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.entries});

  final List<Widget> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: ThemeRadius.circular20,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: context.textTheme.titleMedium?.copyWith(
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
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  secondaryValue!,
                  style: context.textTheme.titleMedium?.copyWith(
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: context.colorScheme.onSurface,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: context.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.textTheme.titleMedium,
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
