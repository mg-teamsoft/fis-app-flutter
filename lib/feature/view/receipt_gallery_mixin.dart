part of '../../page/receipt_gallery.dart';

mixin MixinReceiptGallery on State<PageReceiptGallery> {
 late ReceiptApiService _receiptApiService;
  late ScrollController _scrollController;
  late String _searchQuery;
  // Başlangıçta boş liste ile başlatıyoruz ki 'sort' hata vermesin
  ReceiptGalleryPageState _state = const ReceiptGalleryPageState(
    isLoading: true,
    filteredReceipts: [],
    errorMessage: '',
  );
  List<ReceiptSummary> _rawList = [];

  @override
  void initState() {
    super.initState();
    _receiptApiService = ReceiptApiService();
    _scrollController = ScrollController();
    _searchQuery = '';
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(
          () => _state = _state.copyWith(isLoading: true, errorMessage: ''));

      final data = await _receiptApiService.listReceipts();
      _rawList = data;

      // Veri geldiğinde doğrudan applyFilter çağırıyoruz
      _applyFilter(null);
    } catch (e) {
      setState(() => _state = _state.copyWith(
          isLoading: false, errorMessage: 'Veri yüklenemedi: ${e.toString()}'));
    }
  }

  void _initializeList(List<ReceiptSummary> data) {
    setState(() {
      _state = _state.copyWith(
        filteredReceipts: data,
        isLoading: false,
      );
    });
    _applyFilter(null);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter('search/$query');
    });
  }
void _applyFilter(String? value) {
    setState(() {
      // 1. Önce veriyi 'raw' listeden çekip yeni bir çalışma listesi oluşturuyoruz
      List<ReceiptSummary> workingList = List.from(_rawList);

      // 2. Arama protokolü (search/ paketini aç)
      if (value != null && value.startsWith('search/')) {
        final query = value.replaceFirst('search/', '').toLowerCase();
        workingList = workingList
            .where((r) => (r.businessName).toLowerCase().contains(query))
            .toList();
      }

      // 3. Sıralama (Senin paylaştığın if-else yapısı)
      if (value == 'sort_a_z') {
        workingList.sort((a, b) => a.businessName.compareTo(b.businessName));
      } else if (value == 'sort_z_a') {
        workingList.sort((a, b) => b.businessName.compareTo(a.businessName));
      } else if (value == 'sort_high_price') {
        workingList.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      } else if (value == 'sort_low_price') {
        workingList.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
      } else if (value == 'sort_last_add' || value == null) {
        // Default ve son eklenen aynı mantık
        workingList.sort((a, b) => (b.transactionDate ?? DateTime.now())
            .compareTo(a.transactionDate ?? DateTime.now()));
      } else if (value == 'sort_firt_add') {
        workingList.sort((a, b) => (a.transactionDate ?? DateTime.now())
            .compareTo(b.transactionDate ?? DateTime.now()));
      }

      // 4. State'i Güncelleme (Hatanın çözüldüğü yer)
      _state = _state.copyWith(
        filteredReceipts: workingList, // workingList'in kendisini veriyoruz!
        isLoading: false,
        errorMessage: '',
      );
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _openDetails(ReceiptSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailPage(receiptId: summary.id),
      ),
    );
  }

  Future<void> _reload() async {
    _loadData();
  }
}
