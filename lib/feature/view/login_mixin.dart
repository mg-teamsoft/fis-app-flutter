part of '../../page/login.dart';

mixin MixinLogin on State<PageLogin> {
  late AuthService _auth;
  late TextEditingController _userCtrl;
  late TextEditingController _passCtrl;
  late ScrollController _scrollCtrl;
  late ValueNotifier<LoginPageState> _state;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    _userCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _state = ValueNotifier(const LoginPageState());
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _scrollCtrl.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    _state.value = _state.value.copyWith(
      isLoading: true,
      errorMessage: '',
    );
    try {
      final res = await _auth.login(_userCtrl.text, _passCtrl.text);
      if (!mounted) return;
      _state.value = _state.value.copyWith(isLoading: false);

      if (res.success) {
        // ✅ Safe call: token is already saved by AuthService.login()
        try {
          await context.read<UserPlanProvider>().loadMyPlan();
        } catch (_) {
          // Optional: ignore & continue, or show a soft warning.
        }

        if (!mounted) return;

        // Navigate to your app’s main page (replace with your ReceiptPage etc.)
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _state.value = _state.value.copyWith(
            isLoading: false,
            errorMessage: res.message?.trim().isNotEmpty == true
                ? res.message!
                : 'Giriş başarısız. Lütfen bilgilerinizi kontrol edip tekrar deneyin.');
      }
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(isLoading: false, errorMessage: 'Bağlantı hatası: $e');
    }
  }
}
