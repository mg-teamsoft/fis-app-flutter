import 'dart:async';
import 'dart:ui';
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

  bool _isLoadingInitial = true;
  String? _error;
  List<ReceiptSummary> _allReceipts = [];

  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<ReceiptSummary> _filteredReceipts = [];
  Timer? _debounce;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _isLoadingInitial = true;
      _error = null;
    });
    try {
      final receipts = await _receiptApiService.listReceipts();
      setState(() {
        _allReceipts = receipts;
        _isLoadingInitial = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      saveText: 'Seç',
      cancelText: 'İptal',
      helpText: 'Tarih Aralığı Seçin',
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _onSearchChanged(_searchQuery); // Trigger search again
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
    });
    _onSearchChanged(_searchQuery);
  }

  bool _fuzzyMatch(String pattern, String str) {
    if (pattern.isEmpty) return true;
    int patternIdx = 0;
    int strIdx = 0;
    final pLen = pattern.length;
    final sLen = str.length;

    while (patternIdx < pLen && strIdx < sLen) {
      if (pattern[patternIdx] == str[strIdx]) {
        patternIdx++;
      }
      strIdx++;
    }
    return patternIdx == pLen;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Simulate search delay to show loading indicator
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.isEmpty && _selectedDateRange == null) {
        setState(() {
          _filteredReceipts = [];
          _isSearching = false;
        });
        return;
      }

      final lowerQuery = query.toLowerCase();
      final searchDateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');

      setState(() {
        _filteredReceipts = _allReceipts.where((receipt) {
          bool passesDateRange = true;
          if (_selectedDateRange != null) {
            final date = receipt.transactionDate;
            if (date == null) {
              passesDateRange = false;
            } else {
              final start = _selectedDateRange!.start;
              final end = _selectedDateRange!.end;
              final dateDay = DateTime(date.year, date.month, date.day);
              final startDay = DateTime(start.year, start.month, start.day);
              final endDay = DateTime(end.year, end.month, end.day);
              passesDateRange = dateDay.compareTo(startDay) >= 0 &&
                  dateDay.compareTo(endDay) <= 0;
            }
          }
          if (!passesDateRange) return false;

          if (query.isEmpty) return true;

          final nameMatch =
              _fuzzyMatch(lowerQuery, receipt.businessName.toLowerCase());
          final amountMatch =
              _fuzzyMatch(lowerQuery, receipt.totalAmount.toString());

          bool dateMatch = false;
          if (receipt.transactionDate != null) {
            final dateStr = searchDateFormatter
                .format(receipt.transactionDate!)
                .toLowerCase();
            dateMatch = _fuzzyMatch(lowerQuery, dateStr);
          }

          return nameMatch || amountMatch || dateMatch;
        }).toList();
        _isSearching = false;
      });
    });
  }

  void _openDetails(ReceiptSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailPage(receiptId: summary.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bodyContent;
    if (_isLoadingInitial) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      bodyContent = _GalleryError(
        message: 'Fişler yüklenirken bir hata oluştu.',
        details: _error,
        onRetry: _loadReceipts,
      );
    } else if (_allReceipts.isEmpty) {
      bodyContent = const _GalleryEmptyState();
    } else {
      bodyContent = _ReceiptsList(
        receipts: _allReceipts,
        onOpenDetails: _openDetails,
      );
    }

    final bool showOverlay =
        _searchQuery.isNotEmpty || _selectedDateRange != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Fişler',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Fiş ara (şirket adına göre)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.date_range, size: 16),
                        label: Text(_selectedDateRange == null
                            ? 'Tarih Aralığı Seç'
                            : '${DateFormat('d MMM', 'tr_TR').format(_selectedDateRange!.start)} - ${DateFormat('d MMM', 'tr_TR').format(_selectedDateRange!.end)}'),
                        onPressed: _pickDateRange,
                      ),
                      if (_selectedDateRange != null) ...[
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.clear, size: 16),
                          label: const Text('Temizle'),
                          onPressed: _clearDateRange,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  // Base List
                  bodyContent,

                  // Blur Overlay & Search Results
                  if (showOverlay)
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            color: theme.colorScheme.surface.withOpacity(0.4),
                            child: _isSearching
                                ? const Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 24.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _buildSearchResults(theme),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_filteredReceipts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text(
          'Sonuç bulunamadı.',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final dateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _filteredReceipts.length,
      itemBuilder: (context, index) {
        final receipt = _filteredReceipts[index];
        final date = receipt.transactionDate;
        final dateText =
            date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
        final amountText = currencyFormatter.format(receipt.totalAmount);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerLow,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                FocusScope.of(context).unfocus();
                _openDetails(receipt);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receipt.businessName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amountText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

    final List<Widget> children = [];

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onOpenDetails(summary),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.businessName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  amountText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
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
