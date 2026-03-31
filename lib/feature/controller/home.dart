part of '../page/home.dart';

mixin _ConnectionHome on State<PageHome> {
  late HomeService _homeService;
  late Future<ModelHome> _futureSummary;
  late ScrollController _scrollCtrl;
  late Size _size;

  @override
  void initState() {
    super.initState();
    _homeService = HomeService();
    _scrollCtrl = ScrollController();
    _futureSummary = _homeService.fetchSummary();
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
