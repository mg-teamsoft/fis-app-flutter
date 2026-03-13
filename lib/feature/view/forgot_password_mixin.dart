part of '../../page/forgot_password.dart';

mixin MixinResetPassword on State<PageForgotPassword> {
  late GlobalKey<FormState> _formKey;
  late ScrollController _scrollController;
  late TextEditingController _emailController;
  late AuthService _auth;
  late final ValueNotifier<ForgotPasswordPageState> _state;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _auth = AuthService();
    _state = ValueNotifier(const ForgotPasswordPageState());
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _state.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _controlMail(String? value){
    if (value == null || value.trim().isEmpty) {
      return 'E-posta gerekli';
    }
    final email = value.trim();
    final reg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!reg.hasMatch(email)) {
      return 'Geçerli bir e-posta girin';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _state.value = _state.value.copyWith(
      isLoading: true,
      errorMessage: '',
    );

    try {
      final message = await _auth.requestPasswordReset(
        _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _statusMessage = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      _state.value = _state.value.copyWith(isLoading: false, errorMessage: msg);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İstek başarısız: $msg')),
      );
    } finally {
      if (mounted) {
        _state.value = _state.value.copyWith(isLoading: false);
      }
    }
  }
}
