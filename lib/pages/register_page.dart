import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

import '../app/services/auth_service.dart';
import '../app/services/plan_service.dart';
import '../model/plan_option.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  final _auth = AuthService();
  final _planService = PlanService();
  late Future<List<PlanOption>> _plansFuture;
  String? _selectedPlanKey;

  @override
  void initState() {
    super.initState();
    _plansFuture =
        _planService.fetchPlans().then(PlanService.sortPlansWithFreeFirst);
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

  String? validatePassword(String? value) {
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
      // Go back to login with a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Kayıt başarılı')),
        );
      }
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      setState(() => _error = res.message ?? 'Kayıt başarısız');
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _req,
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _email,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  obscureText: _obscure,
                  validator: validatePassword,
                  onFieldSubmitted: (_) => _onRegister(),
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Plan Seçimi',
                    style: context.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<PlanOption>>(
                  future: _plansFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _PlanLoadingState();
                    }
                    if (snapshot.hasError) {
                      return _PlanErrorState(
                        message: 'Planlar yüklenemedi.',
                        details: snapshot.error?.toString(),
                        onRetry: _retryPlans,
                      );
                    }
                    final plans = snapshot.data ?? const <PlanOption>[];
                    if (plans.isEmpty) {
                      return _PlanErrorState(
                        message: 'Görüntülenecek plan bulunamadı.',
                        onRetry: _retryPlans,
                      );
                    }

                    if (_selectedPlanKey == null && plans.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() => _selectedPlanKey = plans.first.planKey);
                      });
                    }

                    final effectiveSelectedKey =
                        _selectedPlanKey ?? plans.first.planKey;

                    final tiles = <Widget>[];
                    for (var i = 0; i < plans.length; i++) {
                      final plan = plans[i];
                      tiles.add(
                        _PlanTile(
                          plan: plan,
                          selected: plan.planKey == effectiveSelectedKey,
                          onTap: () => setState(
                            () => _selectedPlanKey = plan.planKey,
                          ),
                        ),
                      );
                      if (i < plans.length - 1) {
                        tiles.add(const SizedBox(height: 12));
                      }
                    }
                    return Column(children: tiles);
                  },
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(_error!,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.colorScheme.error)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _onRegister,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Kayıt Ol'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text('Giriş Ekranına Git'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PlanOption plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;
    final backgroundColor = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surface;
    final priceText = plan.billingCycle.isNotEmpty
        ? '${plan.priceLabel}/${plan.billingCycle}'
        : plan.priceLabel;
    final badgeText = (plan.badge != null && plan.badge!.trim().isNotEmpty)
        ? plan.badge!.trim()
        : (plan.isPopular ? 'Popüler' : null);
    final badgeBackground = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.secondaryContainer;
    final badgeForeground = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSecondaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      priceText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.description.isNotEmpty
                      ? plan.description
                      : 'Plan detayları yakında.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (badgeText != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: badgeForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanLoadingState extends StatelessWidget {
  const _PlanLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanErrorState extends StatelessWidget {
  const _PlanErrorState({
    required this.message,
    this.details,
    required this.onRetry,
  });

  final String message;
  final String? details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline,
                  color: theme.colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (details != null && details!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              details!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ),
        ],
      ),
    );
  }
}
