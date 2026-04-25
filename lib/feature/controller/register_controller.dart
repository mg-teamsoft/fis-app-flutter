part of '../page/register_page.dart';

mixin _ConnectionRegister on State<PageRegister> {
  late GlobalKey<FormState> _formKey;
  late ScrollController _scrollController;
  late TextEditingController _userCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;
  late bool _obscure;
  late bool _loading;
  String? _error;

  late CoreEnterApp _coreEnterApp;
  late AuthService _auth;
  late PlanService _planService;
  late Future<List<PlanOption>> _plansFuture;
  String? _selectedPlanKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _scrollController = ScrollController();
    _userCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _obscure = true;
    _loading = false;
    _error = null;
    _auth = AuthService();
    _planService = PlanService();
    _plansFuture =
        _planService.fetchPlans().then(PlanService.sortPlansWithFreeFirst);
    _selectedPlanKey = null;
    _coreEnterApp = CoreEnterApp();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _auth.register(
      userName: _userCtrl.text,
      password: _passCtrl.text,
      email: _emailCtrl.text,
      planKey: _selectedPlanKey,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ThemeTypography.bodyLarge(
              context,
              res.message ?? 'Kayıt başarılı',
              color: context.theme.success,
              weight: FontWeight.w600,
            ),
          ),
        );
      }
      await Navigator.of(context).pushReplacementNamed('/login');
    } else {
      setState(() => _error = res.message ?? 'Kayıt başarısız');
    }
  }

  void _retryPlans() {
    setState(() {
      _plansFuture =
          _planService.fetchPlans().then(PlanService.sortPlansWithFreeFirst);
    });
  }

  void _onPlanSelected(String planKey) {
    setState(() => _selectedPlanKey = planKey);
  }
}
