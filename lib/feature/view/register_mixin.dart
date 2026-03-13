part of '../../page/register.dart';

mixin MixinRegister on State<PageRegister> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _userCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;
  late ScrollController _scrollCtrl;

  late AuthService _auth;
  late PlanService _planService;
  late Future<List<PlanOption>> _plansFuture;
  String? _selectedPlanKey;
  late final ValueNotifier<RegisterPageState> _state;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _userCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _auth = AuthService();
    _planService = PlanService();
    _state = ValueNotifier(const RegisterPageState());
    _plansFuture =
        _planService.fetchPlans().then(PlanService.sortPlansWithFreeFirst);
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _retryPlans() {
    setState(() {
      _plansFuture =
          _planService.fetchPlans().then(PlanService.sortPlansWithFreeFirst);
    });
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null;
  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Zorunlu alan';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim());
    return ok ? null : 'E-posta adresi geçersiz';
  }

  String? _validatePassword(String? value) {
    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,}$');

    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (!regex.hasMatch(value)) {
      return 'Use min 8 chars, at least (1 uppercase & 1 lowercase & 1 number & 1 special) char.';
    }
    return null;
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _state.value = _state.value.copyWith(
      isLoading: true,
      errorMessage: '',
    );

    final res = await _auth.register(
      userName: _userCtrl.text,
      password: _passCtrl.text,
      email: _emailCtrl.text,
      planKey: _selectedPlanKey,
    );

    try {
      if (!mounted) return;
      _state.value = _state.value.copyWith(isLoading: false);

      if (res.success) {
        // Go back to login with a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Kayıt başarılı')),
          );
        }
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        _state.value = _state.value.copyWith(
            isLoading: false,
            errorMessage:
                'Kayıt başarısız. Lütfen bilgilerinizi kontrol edip tekrar deneyin.');
      }
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(isLoading: false, errorMessage: 'Bağlantı hatası: $e');
    }
  }
}
