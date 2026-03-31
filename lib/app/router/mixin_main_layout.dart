part of './main_layout.dart';

mixin _MixinMainLayout on State<MainLayout> {
  late AuthService _auth;

  late String _currentRoute;
  Object? _currentArguments;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    _currentRoute = _normalizeRoute(widget.initialRoute);
    _currentArguments = widget.initialArguments;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UserPlanProvider>().loadMyPlan();
    });
  }

  static const List<String> _navRoutes = [
    '/home',
    '/gallery',
    '/connections',
    '/settings',
  ];

  late final Map<String, Widget Function(BuildContext, Object?)> _pageBuilders =
      {
    '/home': (_, __) => const PageHome(),
    '/about': (_, __) => const PageAbout(),
    '/accountSettings': (_, __) => const PageAccountSettings(),
    '/excelFiles': (_, __) => const PageExcel(),
    '/receipt': (_, __) => const PageReceipt(),
    '/gallery': (_, __) => const PageReceiptGallery(),
    '/settings': (_, __) => const PageSettings(),
    '/receipt/process': (_, args) {
      final files = (args is List<XFile>) ? args : const <XFile>[];
      return PageReceiptProcess(files: files);
    },
    '/receipt/results': (_, args) {
      final items =
          (args is List<SelectedItem>) ? args : const <SelectedItem>[];
      return PageReceiptResult(items: items);
    },
    '/receipt/manuel': (_, __) => const PageReceiptManuel(),
  };

  String _normalizeRoute(String route) {
    return _pageBuilders.containsKey(route) ? route : '/home';
  }

  void _setCurrentRoute(String route, {Object? arguments}) {
    final normalized = _normalizeRoute(route);
    setState(() {
      _currentRoute = normalized;
      _currentArguments = arguments;
    });
  }

  Widget _buildCurrentPage(BuildContext context) {
    final builder = _pageBuilders[_currentRoute];
    if (builder == null) {
      return const Center(child: Text('Sayfa bulunamadı'));
    }
    return builder(context, _currentArguments);
  }

  void _onTabTapped(int index) {
    if (index < 0 || index >= _navRoutes.length) return;
    final route = _navRoutes[index];
    if (route == _currentRoute) return;
    _setCurrentRoute(route);
  }

  int get _currentNavIndex {
    final index = _navRoutes.indexOf(_currentRoute);
    if (index >= 0) {
      return index;
    }
    return 0;
  }

  Future<void> _handleMenuSelection(String value) async {
    if (value == 'logout') {
      await _auth.logout();
      if (mounted) {
        await Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    _setCurrentRoute(value);
  }
}
