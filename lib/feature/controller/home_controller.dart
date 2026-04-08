part of '../page/home_page.dart';

mixin _ConnectionHome on State<PageHome> {
  late HomeService _homeService;
  late Future<ModelHome> _futureSummary;
  late ScrollController _scrollCtrl;
  late Size _size;
  late DateTime _date;
  late String _dateString;

  final List<String> _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  @override
  void initState() {
    super.initState();
    _homeService = HomeService();
    _scrollCtrl = ScrollController();
    _futureSummary = _homeService.fetchSummary();
    _date = DateTime.now();
    _dateString = '${_months[_date.month - 1]} ${_date.year}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _futureSummary = _homeService.fetchSummary();
    });
    try {
      await _futureSummary;
    } on Exception catch (_) {
      // Swallow the error so the refresh animation can complete.
    }
  }
}
