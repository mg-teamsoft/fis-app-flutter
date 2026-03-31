part of '../page/receipt_gallery.dart';

mixin _ConnectionReceiptGallery on State<PageReceiptGallery> {
  late ReceiptApiService _receiptApiService;
  late bool _isLoadingInitial;
  late String? _error;
  late List<ModelReceipt> _allReceipts;

  // Search state
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late String _searchQuery;
  late bool _isSearching;
  late List<ModelReceipt> _filteredReceipts;
  late Timer? _debounce;
  late DateTimeRange? _selectedDateRange;
  late bool _showOverlay;

  @override
  void initState() {
    super.initState();
    _receiptApiService = ReceiptApiService();
    _isLoadingInitial = true;
    _error = null;
    _allReceipts = [];
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _searchQuery = '';
    _isSearching = false;
    _filteredReceipts = [];
    _debounce = null;
    _selectedDateRange = null;
    _showOverlay = _searchQuery.isNotEmpty || _selectedDateRange != null;
    unawaited(_loadReceipts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
      if (!mounted) return;
      setState(() {
        _allReceipts = receipts;
        _isLoadingInitial = false;
      });
    } on Exception catch (e) {
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            //Header background color
            primaryColor: context.colorScheme.secondary,
            //Background color
            scaffoldBackgroundColor: context.colorScheme.surface,
            //Divider color
            dividerColor: context.colorScheme.outline,
            //Non selected days of the month color
            textTheme: TextTheme(
              bodyMedium: context.textTheme.bodyMedium!.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              //Selected dates background color
              primary: context.colorScheme.primary,
              //Month title and week days color
              onSurface: context.colorScheme.onSurface,
              //Header elements and selected dates text color
              onPrimary: context.colorScheme.onSurface,
            ),
            appBarTheme: const AppBarTheme().copyWith(
              backgroundColor: context.colorScheme.surfaceContainerHigh,
              foregroundColor: context.colorScheme.onSurfaceVariant,
            ),
          ),
          child: child!,
        );
      },
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
    var patternIdx = 0;
    var strIdx = 0;
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
          var passesDateRange = true;
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

          var dateMatch = false;
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

  Future<void> _openDetails(ModelReceipt summary) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PageReceiptDetail(receiptId: summary.id),
      ),
    );
  }
}
