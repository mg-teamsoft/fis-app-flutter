part of '../page/reset_password_page.dart';

mixin _ConnectionResetPassword on State<PageResetPassword> {
  late ScrollController _scrollController;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _passwordCtrl;
  late TextEditingController _confirmCtrl;
  late AuthService _auth;

  late String? _token;
  late bool _submitting;
  late String? _status;
  late String? _error;
  bool _enterStatus = false;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    _scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    _passwordCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
    _token = widget.initialToken;
    _submitting = false;
    _status = null;
    _error = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _enterStatus = args['init'] == true;
      });
    } else if (widget.init != null) {
      setState(() {
        _enterStatus = widget.init!;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_token == null || _token!.isEmpty) {
      setState(() => _error = 'Geçersiz veya eksik token.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz veya eksik token.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _status = null;
      _error = null;
    });

    final res = await _auth.resetPassword(
      token: _token!,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (res.success) {
        _status = res.message ?? 'Şifre başarıyla güncellendi.';
      } else {
        _error = res.message ?? 'İşlem başarısız.';
      }
    });

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_status!)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) await Navigator.of(context).pushReplacementNamed('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!)),
      );
    }
  }
}
