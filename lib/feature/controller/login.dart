part of '../page/login.dart';

mixin _ConnectionLogin on State<PageLogin> {
  late AuthService _auth;
  late ScrollController _scrollController;
  late TextEditingController _userCtrl;
  late TextEditingController _passCtrl;
  late bool _loading;
  String? _error;
  late Size _size;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    _scrollController = ScrollController();
    _userCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _loading = false;
    _error = null;
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.of(context).size;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _auth.login(_userCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      // ✅ Safe call: token is already saved by AuthService.login()
      try {
        await context.read<UserPlanProvider>().loadMyPlan();
      } on Exception catch (_) {
        // Optional: ignore & continue, or show a soft warning.
      }

      if (!mounted) return;

      // Navigate to your app’s main page (replace with your ReceiptPage etc.)
      await Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _error =
          'Giriş başarısız. Lütfen bilgilerinizi kontrol edip tekrar deneyin.');
    }
  }
}
