part of '../../page/home.dart';

mixin MixinHome on State<PageHome> {
  late HomeService _homeService;
  late Future<HomeSummary> _futureSummary;
  late ScrollController _scrollCtrl;
  late double _width;

  @override
  void initState() {
    super.initState();
    _homeService = HomeService();
    _scrollCtrl = ScrollController();
    _futureSummary = _homeService.fetchSummary();
  }

  @override
  void didChangeDependencies() {
    _width = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
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
    } catch (_) {
      // Swallow the error so the refresh animation can complete.
    }
  }
}
