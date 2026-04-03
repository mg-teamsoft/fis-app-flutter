part of '../page/forget_password.dart';

mixin _ConnectionForgotPassword on State<PageForgotPassword> {
  late ScrollController _scrollController;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late AuthService _auth;

  late bool _loading;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _auth = AuthService();
    _loading = false;
    _statusMessage = null;
    _errorMessage = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final message = await _auth.requestPasswordReset(
        _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _statusMessage = message.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusMessage ?? '')),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() => _errorMessage = msg);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İstek başarısız: $msg')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
