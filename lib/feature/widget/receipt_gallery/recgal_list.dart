part of '../../page/receipt_gallery_page.dart';

const int _kPageSize = 10;

final class _ReceiptsList extends StatefulWidget {
  const _ReceiptsList({
    required this.receipts,
    required this.onOpenDetails,
  });

  final List<ModelReceipt> receipts;
  final void Function(ModelReceipt) onOpenDetails;

  @override
  State<_ReceiptsList> createState() => _ReceiptsListState();
}

class _ReceiptsListState extends State<_ReceiptsList> {
  /// Tracks which month groups are expanded (by label).
  final Set<String> _expandedMonths = {};

  /// Tracks the current page index per month group (by label).
  final Map<String, int> _pagePerMonth = {};

  /// Whether we've done the initial expand of the most recent month.
  bool _didInitialExpand = false;

  List<_ReceiptMonthGroup> _buildGroups() {
    final monthFormatter = DateFormat('MMMM yyyy', 'tr_TR');

    final grouped = <DateTime?, List<ModelReceipt>>{};
    for (final receipt in widget.receipts) {
      final date = receipt.transactionDate;
      final key = (date == null) ? null : DateTime(date.year, date.month);
      grouped.putIfAbsent(key, () => []).add(receipt);
    }

    final groups = grouped.entries.map((entry) {
      final items = [...entry.value]..sort((a, b) {
          final aDate =
              a.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              b.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      final label = entry.key != null
          ? capitalize(monthFormatter.format(entry.key!))
          : 'Tarihsiz';
      return _ReceiptMonthGroup(label: label, items: items, sortKey: entry.key);
    }).toList()
      ..sort((a, b) {
        if (a.sortKey == null && b.sortKey == null) return 0;
        if (a.sortKey == null) return 1;
        if (b.sortKey == null) return -1;
        return b.sortKey!.compareTo(a.sortKey!);
      });

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    final groups = _buildGroups();

    // Auto-expand the most recent month on first build
    if (!_didInitialExpand && groups.isNotEmpty) {
      _expandedMonths.add(groups.first.label);
      _didInitialExpand = true;
    }

    return ListView.builder(
      padding: const ThemePadding.marginBottom32(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final isExpanded = _expandedMonths.contains(group.label);
        final currentPage = _pagePerMonth[group.label] ?? 0;
        final totalItems = group.items.length;
        final needsPagination = totalItems >= _kPageSize;
        final totalPages = (totalItems / _kPageSize).ceil();

        // Calculate paginated slice
        final startIndex = needsPagination ? currentPage * _kPageSize : 0;
        final endIndex = needsPagination
            ? (startIndex + _kPageSize).clamp(0, totalItems)
            : totalItems;
        final visibleItems = group.items.sublist(startIndex, endIndex);

        return Padding(
          padding: const ThemePadding.horizontalSymmetricMedium(),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: ThemeRadius.circular16,
              side: BorderSide(
                color: context.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            color: context.colorScheme.surface,
            child: Column(
              children: [
                // ── Month Header (tap to expand/collapse) ──
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedMonths.remove(group.label);
                      } else {
                        _expandedMonths.add(group.label);
                      }
                    });
                  },
                  child: Padding(
                    padding: const ThemePadding.horizontalSymmetric(),
                    child: Row(
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: context.colorScheme.primary,
                          size: ThemeSize.iconLarge,
                        ),
                        const SizedBox(width: ThemeSize.spacingM),
                        Expanded(
                          child: ThemeTypography.titleMedium(
                            context,
                            group.label,
                            color: context.colorScheme.primary,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const ThemePadding.verticalSymmetricSmall(),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primaryContainer
                                .withValues(alpha: 0.6),
                            borderRadius: ThemeRadius.circular12,
                          ),
                          child: ThemeTypography.labelMedium(
                            context,
                            '$totalItems fiş',
                            color: context.colorScheme.onPrimaryContainer,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Expanded Content ──
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      Divider(
                        height: 1,
                        color:
                            context.colorScheme.outline.withValues(alpha: 0.12),
                      ),
                      // Receipt tiles
                      ...visibleItems.map((receipt) {
                        final date = receipt.transactionDate;
                        final dateText = date != null
                            ? dateFormatter.format(date)
                            : 'Tarih bilgisi yok';
                        return Padding(
                          padding:
                              const ThemePadding.horizontalSymmetricMedium(),
                          child: _ReceiptListTile(
                            summary: receipt,
                            dateText: dateText,
                            amountText:
                                currencyFormatter.format(receipt.totalAmount),
                            onOpenDetails: widget.onOpenDetails,
                          ),
                        );
                      }),

                      // ── Pagination Controls ──
                      if (needsPagination)
                        Padding(
                          padding: const ThemePadding.marginBottom12(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: currentPage > 0
                                    ? () {
                                        setState(() {
                                          _pagePerMonth[group.label] =
                                              currentPage - 1;
                                        });
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.chevron_left_rounded,
                                  color: currentPage > 0
                                      ? context.colorScheme.primary
                                      : context.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: currentPage > 0
                                      ? context.colorScheme.primaryContainer
                                          .withValues(alpha: 0.3)
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const ThemePadding
                                    .horizontalSymmetricMedium(),
                                child: ThemeTypography.bodyMedium(
                                  context,
                                  '${currentPage + 1} / $totalPages',
                                  weight: FontWeight.w600,
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                              IconButton(
                                onPressed: currentPage < totalPages - 1
                                    ? () {
                                        setState(() {
                                          _pagePerMonth[group.label] =
                                              currentPage + 1;
                                        });
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.chevron_right_rounded,
                                  color: currentPage < totalPages - 1
                                      ? context.colorScheme.primary
                                      : context.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: currentPage < totalPages - 1
                                      ? context.colorScheme.primaryContainer
                                          .withValues(alpha: 0.3)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration:
                      const Duration(milliseconds: 350), // ← animation speed
                  sizeCurve: Curves.easeIn, // ← animation curve
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
