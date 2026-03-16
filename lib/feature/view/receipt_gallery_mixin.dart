part of '../../page/receipt_gallery.dart';

mixin MixinReceiptGallery on State<PageReceiptGallery> {
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

  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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


  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
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

  void _openDetails(ReceiptSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailPage(receiptId: summary.id),
      ),
    );
  }
}
