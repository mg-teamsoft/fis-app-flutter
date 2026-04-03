import 'package:flutter/material.dart';

import '../app/services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.initialToken});
  final String? initialToken;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();

  String? _token;
  bool _submitting = false;
  String? _status;
  String? _error;

  @override
  void initState() {
    super.initState();
    _token = widget.initialToken;
  }

  @override
  void dispose() {
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
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifreyi Sıfırla'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'E-postadaki bağlantıyı açarak geldiniz. Yeni şifrenizi belirleyin.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Şifre gerekli';
                  if (v.length < 8) return 'En az 8 karakter olmalı';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Şifre Tekrar',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (v) {
                  if (v != _passwordCtrl.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _status!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Şifreyi Sıfırla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
