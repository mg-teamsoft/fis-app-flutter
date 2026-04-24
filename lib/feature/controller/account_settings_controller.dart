part of '../page/account_settings_page.dart';

mixin _ConnectionAccountSettings on State<PageAccountSettings> {
  final Set<String> _fallbackProductIds = <String>{
    'com.myfisapp.sub.monthly100',
    'com.myfisapp.sub.yearly1200',
    'com.myfisapp.consumable.100scans',
  };

  final double _navSpacer = kBottomNavigationBarHeight + 12;

  final _userService = UserService();
  final _planService = PlanService();
  final _purchaseTransactionService = PurchaseTransactionService();
  final _scrollController = ScrollController();

  UserProfile? _user;
  List<PlanOption> _allPlans = const [];
  List<PlanOption> _subscriptionPlans = const [];
  PlanOption? _currentPlan;
  List<PlanOption> _plans = const [];
  String? _selectedPlanKey;
  String? _currentPlanKey;
  String? _userPlanId;
  List<PurchaseTransaction> _transactions = const [];
  int _visibleTransactions = 5;
  String? _transactionError;

  bool _loading = true;
  bool _updatingPlan = false;
  bool _resendingVerification = false;
  String? _error;
  bool _iapInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    unawaited(_loadAll());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_visibleTransactions < _transactions.length) {
        setState(() {
          _visibleTransactions += 5;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await _userService.fetchCurrentUser();
      final fetchedPlans = await _planService.fetchPlans();
      final sortedAllPlans = PlanService.sortPlansWithFreeFirst(fetchedPlans);
      final subscriptionPlans = sortedAllPlans.where((plan) {
        return (plan.productType ?? '').toLowerCase() == 'subscription' &&
            plan.active;
      }).toList();
      final userPlan = await _planService.fetchUserPlanKey();
      var transactions = const <PurchaseTransaction>[];
      String? transactionError;
      try {
        transactions = await _purchaseTransactionService.listTransactions();
      } on Exception catch (e) {
        transactionError = e.toString();
      }

      if (!mounted) return;
      setState(() {
        _user = user;
        final up = Provider.of<UserPlanProvider?>(context, listen: false);
        final providerPlanKey = up?.planKey.trim().toUpperCase();
        final serverPlanKey = userPlan?.planKey.trim();
        final providerHasAppleEntitlement = providerPlanKey != null &&
            providerPlanKey.isNotEmpty &&
            providerPlanKey != 'FREE';
        _currentPlanKey = providerHasAppleEntitlement
            ? providerPlanKey
            : (serverPlanKey != null && serverPlanKey.isNotEmpty)
                ? serverPlanKey
                : (providerPlanKey != null && providerPlanKey.isNotEmpty)
                    ? providerPlanKey
                    : (subscriptionPlans.isNotEmpty
                        ? subscriptionPlans.first.planKey
                        : null);
        _currentPlan = sortedAllPlans
                .where((plan) => plan.planKey == _currentPlanKey)
                .isNotEmpty
            ? sortedAllPlans
                .firstWhere((plan) => plan.planKey == _currentPlanKey)
            : null;
        _allPlans = sortedAllPlans
            .where((plan) => plan.planKey != _currentPlanKey)
            .toList();
        _subscriptionPlans = subscriptionPlans;
        _plans = sortedAllPlans
            .where((plan) => plan.active && plan.planKey != _currentPlanKey)
            .toList();
        debugPrint('Current plan key: $_currentPlanKey');
        debugPrint(
          'Available plans: ${_plans.map((p) => p.planKey).join(', ')}',
        );

        _selectedPlanKey = null;
        _userPlanId = userPlan?.id;
        _transactions = transactions;
        _transactionError = transactionError;
      });

      if (!_iapInitialized) {
        final pp = Provider.of<PurchaseProvider>(context, listen: false);
        await pp.init(_productIdsFromPlans());
        _iapInitialized = true;
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onRefresh() => _loadAll();

  String? _productIdForPlanKey(String planKey) {
    switch (planKey) {
      case 'MONTHLY_100':
        return 'com.myfisapp.sub.monthly100';
      case 'YEARLY_1200':
        return 'com.myfisapp.sub.yearly1200';
      case 'ADDITIONAL_100':
        return 'com.myfisapp.consumable.100scans';
      default:
        return null;
    }
  }

  String? _productIdForPlan(PlanOption plan) {
    if (plan.storeIds.isNotEmpty) {
      final match = plan.storeIds.entries.firstWhere(
        (entry) {
          final key = entry.key.toLowerCase();
          return key.contains('apple') ||
              key.contains('ios') ||
              key.contains('appstore') ||
              key.contains('storekit');
        },
        orElse: () => const MapEntry('', ''),
      );
      if (match.value.isNotEmpty) {
        return match.value;
      }
    }
    return _productIdForPlanKey(plan.planKey);
  }

  Set<String> _productIdsFromPlans() {
    final ids = <String>{};
    for (final plan in _allPlans) {
      final id = _productIdForPlan(plan);
      if (id != null && id.isNotEmpty) {
        ids.add(id);
      }
    }
    return ids.isNotEmpty ? ids : _fallbackProductIds;
  }

  List<PlanOption> _availablePlansForCurrent(String? currentPlanKey) {
    return _subscriptionPlans
        .where((plan) => plan.planKey != currentPlanKey)
        .toList();
  }

  PlanOption? _findPlanByKey(String? key) {
    if (key == null) return null;
    for (final plan in _allPlans) {
      if (plan.planKey == key) return plan;
    }
    return null;
  }

  PlanOption? get _selectedPlan {
    final key = _selectedPlanKey;
    if (key == null) return null;
    for (final plan in _plans) {
      if (plan.planKey == key) return plan;
    }
    return null;
  }

  PlanOption? get _activePlan {
    if (_currentPlan != null) return _currentPlan;
    final current = _findPlanByKey(_currentPlanKey);
    if (current != null) return current;
    if (_subscriptionPlans.isNotEmpty) return _subscriptionPlans.first;
    return _allPlans.isNotEmpty ? _allPlans.first : null;
  }

  // ignore: unused_element
  PlanOption? get _additionalPlan {
    for (final plan in _allPlans) {
      final key = plan.planKey.toLowerCase();
      final type = (plan.productType ?? '').toLowerCase();
      debugPrint('Plan key: $key');
      debugPrint('Plan type: $type');
      if (key.contains('additional') || type == 'consumable') {
        return plan;
      }
    }
    return null;
  }

  Color _availablePlanBackground(int index) {
    const palette = <Color>[
      Color(0xFFDCEEFF),
      Color(0xFFDCF7EA),
      Color(0xFFFFECD6),
    ];
    return palette[index % palette.length];
  }

  Color _availablePlanBorder(int index) {
    const palette = <Color>[
      Color(0xFF84CAFF),
      Color(0xFF75E0A7),
      Color(0xFFFDBA74),
    ];
    return palette[index % palette.length];
  }

  Future<void> _buyPlan(
    PlanOption plan, {
    required bool syncCurrentPlan,
  }) async {
    final pp = Provider.of<PurchaseProvider>(context, listen: false);
    if (!_iapInitialized) {
      await pp.init(_productIdsFromPlans());
      _iapInitialized = true;
    }
    if (!mounted) return;

    final productId = _productIdForPlan(plan);
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Bu plan bulunamadı.',
            color: context.colorScheme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
      return;
    }

    ProductDetails? product;
    for (final p in pp.products) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            "Plan App Store'da mevcut değil.",
            color: context.colorScheme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
      return;
    }

    await pp.buy(product);

    if (!syncCurrentPlan || !mounted) return;
    final up = Provider.of<UserPlanProvider?>(context, listen: false);
    if (up != null) {
      await up.loadMyPlan();
      if (!mounted) return;
      setState(() {
        _currentPlanKey = up.planKey;
        _currentPlan = _subscriptionPlans
                .where((plan) => plan.planKey == _currentPlanKey)
                .isNotEmpty
            ? _subscriptionPlans
                .firstWhere((plan) => plan.planKey == _currentPlanKey)
            : _currentPlan;
        _plans = _availablePlansForCurrent(_currentPlanKey);
        _selectedPlanKey = null;
      });
    }
  }

  Future<void> _onUpdatePlan() async {
    final selected = _selectedPlanKey;
    if (selected == null || selected == _currentPlanKey) return;

    final selectedPlan = _selectedPlan;
    if (selectedPlan == null) return;

    setState(() => _updatingPlan = true);
    try {
      if (selected == 'FREE') {
        if (_userPlanId == null || _userPlanId!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ThemeTypography.bodyLarge(
                context,
                'Güncellenecek kullanıcı planı bulunamadı.',
                color: context.colorScheme.error,
                weight: FontWeight.w700,
              ),
            ),
          );
          return;
        }
        await _planService.updateUserPlan(
          userPlanId: _userPlanId!,
          planKey: selected,
        );

        if (!mounted) return;
        setState(() {
          _currentPlanKey = selected;
          _currentPlan = null;
          _plans = _availablePlansForCurrent(_currentPlanKey);
          _selectedPlanKey = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ThemeTypography.bodyLarge(
              context,
              'Plan güncellendi.',
              color: context.theme.success,
              weight: FontWeight.w700,
            ),
          ),
        );
        return;
      }

      await _buyPlan(selectedPlan, syncCurrentPlan: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Plan güncellendi.',
            color: context.theme.success,
            weight: FontWeight.w700,
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Plan güncelleme başarısız: $e',
            color: context.colorScheme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingPlan = false);
      }
    }
  }

  Future<void> _onBuyAdditional(PlanOption plan) async {
    setState(() => _updatingPlan = true);
    try {
      await _buyPlan(plan, syncCurrentPlan: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Ek kota satın alındı.',
            color: context.theme.success,
            weight: FontWeight.w700,
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Satın alma başarısız: $e',
            color: context.colorScheme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingPlan = false);
      }
    }
  }

  // ignore: unused_element
  void _onPlanSelected(String planKey) {
    setState(() => _selectedPlanKey = planKey);
  }

  Future<void> _onResendVerification() async {
    final email = _user?.email ?? '';
    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'E-posta adresi bulunamadı.',
            color: context.theme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
      return;
    }

    setState(() => _resendingVerification = true);
    try {
      await _userService.resendVerificationEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Doğrulama e-postası gönderildi.',
            color: context.theme.info,
            weight: FontWeight.w700,
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'İşlem başarısız: $e',
            color: context.colorScheme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _resendingVerification = false);
      }
    }
  }

  Future<void> _onResetPassword() async {
    await Navigator.of(context).pushNamed(
      '/resetPassword',
      arguments: {'init': true},
    );
  }
}
