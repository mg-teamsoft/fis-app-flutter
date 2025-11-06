import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  final _auth = AuthService();

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _auth.login(_userCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      // Navigate to your app’s main page (replace with your ReceiptPage etc.)
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _error = res.message ?? 'Giriş başarısız');
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                prefixIcon: Icon(Icons.person),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon:
                      Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              obscureText: _obscure,
              onSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _handleLogin,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Giriş'),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/register'),
              child: const Text('Hesap Oluştur'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/forgotPassword'),
              child: const Text('Şifremi Unuttum'),
            ),
          ],
        ),
      ),
    );
  }
}
