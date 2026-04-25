part of './main_layout.dart';

mixin _MixinMainLayout on State<MainLayout> {
  late AuthService _auth;

  late String _currentRoute;
  Object? _currentArguments;
  final List<({String route, Object? args})> _routeHistory = [];

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
    '/home', // 0
    '/gallery', // 1
    '/connections', // 2
    '/settings', // 3
    '/notification', // 4
    '/accountSettings', // 5
    '/about', // 6
    '/excelFiles', // 7
    '/receipt', // 8
    '/receipt/process', // 9
    '/receipt/results', // 10
    '/receipt/manuel', // 11
    '/resetPassword', // 12
  ];

  late final Map<String, Widget Function(BuildContext, Object?)> _pageBuilders =
      {
    '/home': (_, __) => const PageHome(),
    '/about': (_, __) => const PageAbout(),
    '/accountSettings': (_, __) => const PageAccountSettings(),
    '/connections': (_, args) {
      final initialTab = (args is Map) ? (args['tab'] as int?) : null;
      return PageConnections(initialTabIndex: initialTab);
    },
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
    '/notification': (_, __) => const PageNotification(),
    '/resetPassword': (_, args) {
      final isInit = (args is Map<String, dynamic>) && (args['init'] == true);
      return PageResetPassword(init: isInit);
    },
  };

  String _normalizeRoute(String route) {
    return _pageBuilders.containsKey(route) ? route : '/home';
  }

  void _setCurrentRoute(
    String route, {
    Object? arguments,
    bool isBottomBarTab = false,
  }) {
    final normalized = _normalizeRoute(route);
    if (_currentRoute == normalized && arguments == _currentArguments) return;

    setState(() {
      if (isBottomBarTab) {
        _routeHistory.clear();
      } else {
        _routeHistory.add((route: _currentRoute, args: _currentArguments));
      }
      _currentRoute = normalized;
      _currentArguments = arguments;
    });
  }

  void _onBackPressed() {
    if (_routeHistory.isNotEmpty) {
      final previous = _routeHistory.removeLast();
      setState(() {
        _currentRoute = previous.route;
        _currentArguments = previous.args;
      });
    } else {
      if (_currentRoute != '/home') {
        setState(() {
          _currentRoute = '/home';
          _currentArguments = null;
        });
      }
    }
  }

  Widget _buildCurrentPage(BuildContext context) {
    final builder = _pageBuilders[_currentRoute];
    if (builder == null) {
      return Center(
        child: ThemeTypography.bodyLarge(
          context,
          'Sayfa bulunamadı',
          weight: FontWeight.w600,
          color: context.colorScheme.error,
        ),
      );
    }
    return builder(context, _currentArguments);
  }

  void _onTabTapped(int index) {
    if (index < 0 || index >= _navRoutes.length) return;
    final route = _navRoutes[index];
    if (route == _currentRoute) return;
    // Bottom bar tabları index 0 ile 3 arasındadır
    _setCurrentRoute(route, isBottomBarTab: index <= 3);
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
