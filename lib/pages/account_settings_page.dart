import 'package:flutter/material.dart';

import '../models/plan_option.dart';
import '../models/user_profile.dart';
import '../services/plan_service.dart';
import '../services/user_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _userService = UserService();
  final _planService = PlanService();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _maskedPasswordController = TextEditingController(text: '********');

  UserProfile? _user;
  List<PlanOption> _plans = const [];
  String? _selectedPlanKey;
  String? _currentPlanKey;
  String? _userPlanId;

  bool _loading = true;
  bool _updatingPlan = false;
  bool _resendingVerification = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _maskedPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await _userService.fetchCurrentUser();
      final plans = PlanService.sortPlansWithFreeFirst(
        await _planService.fetchPlans(),
      );
      final userPlan = await _planService.fetchUserPlanKey();

      if (!mounted) return;
      setState(() {
        _user = user;
        _plans = plans;
        _currentPlanKey = userPlan?.planKey ??
            ((plans.isNotEmpty) ? plans.first.planKey : null);
        _selectedPlanKey =
            _currentPlanKey ?? (plans.isNotEmpty ? plans.first.planKey : null);
        _userPlanId = userPlan?.id;

        _emailController.text = user.email;
        _usernameController.text = user.userName;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onRefresh() => _loadAll();

  Future<void> _onUpdatePlan() async {
    final selected = _selectedPlanKey;
    if (selected == null || selected == _currentPlanKey) return;
    if (_userPlanId == null || _userPlanId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Güncellenecek kullanıcı planı bulunamadı.'),
        ),
      );
      return;
    }
    setState(() => _updatingPlan = true);
    try {
      await _planService.updateUserPlan(
        userPlanId: _userPlanId!,
        planKey: selected,
      );
      if (!mounted) return;
      setState(() {
        _currentPlanKey = selected;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan güncellendi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan güncellenemedi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingPlan = false);
      }
    }
  }

  Future<void> _onResendVerification() async {
    final email = _user?.email ?? '';
    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta adresi bulunamadı.')),
      );
      return;
    }

    setState(() => _resendingVerification = true);
    try {
      await _userService.resendVerificationEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama e-postası gönderildi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem başarısız: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _resendingVerification = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorView(
        message: 'Veriler alınırken bir sorun oluştu.',
        details: _error,
        onRetry: _loadAll,
      );
    }
    if (_user == null) {
      return _ErrorView(
        message: 'Kullanıcı bilgisi bulunamadı.',
        onRetry: _loadAll,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hesap Ayarları',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _AccountDetailsSection(
            emailController: _emailController,
            usernameController: _usernameController,
            passwordController: _maskedPasswordController,
            isEmailVerified: _user!.emailVerified,
            onResendVerification: _onResendVerification,
            resending: _resendingVerification,
          ),
          const SizedBox(height: 24),
          _PlanSelectionSection(
            plans: _plans,
            selectedPlanKey: _selectedPlanKey,
            currentPlanKey: _currentPlanKey,
            onSelect: (plan) => setState(() {
              _selectedPlanKey = plan.planKey;
            }),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_selectedPlanKey == null ||
                    _selectedPlanKey == _currentPlanKey ||
                    _updatingPlan)
                ? null
                : _onUpdatePlan,
            child: _updatingPlan
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Planı Güncelle'),
          ),
        ],
      ),
    );
  }
}

class _AccountDetailsSection extends StatelessWidget {
  const _AccountDetailsSection({
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.isEmailVerified,
    required this.onResendVerification,
    required this.resending,
  });

  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isEmailVerified;
  final VoidCallback onResendVerification;
  final bool resending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesap Bilgileri',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        if (!isEmailVerified) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'E-posta doğrulanmadı',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: resending ? null : onResendVerification,
                child: resending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Doğrulama Gönder'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: usernameController,
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          decoration: const InputDecoration(
            labelText: 'Kullanıcı Adı',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          readOnly: true,
          obscureText: true,
          enableInteractiveSelection: false,
          showCursor: false,
          decoration: const InputDecoration(
            labelText: 'Parola',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: Icon(Icons.visibility_off),
          ),
        ),
      ],
    );
  }
}

class _PlanSelectionSection extends StatelessWidget {
  const _PlanSelectionSection({
    required this.plans,
    required this.selectedPlanKey,
    required this.currentPlanKey,
    required this.onSelect,
  });

  final List<PlanOption> plans;
  final String? selectedPlanKey;
  final String? currentPlanKey;
  final void Function(PlanOption) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Abonelik Planın',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...plans.map((plan) {
          final selected = plan.planKey == selectedPlanKey;
          final isCurrent = plan.planKey == currentPlanKey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanChoiceTile(
              plan: plan,
              selected: selected,
              isCurrent: isCurrent,
              onTap: () => onSelect(plan),
            ),
          );
        }),
      ],
    );
  }
}

class _PlanChoiceTile extends StatelessWidget {
  const _PlanChoiceTile({
    required this.plan,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
  });

  final PlanOption plan;
  final bool selected;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;
    final background = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surface;
    final priceSuffix =
        plan.billingCycle.isNotEmpty ? '/${plan.billingCycle}' : '';
    final priceText = '${plan.priceLabel}$priceSuffix';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description.isNotEmpty
                            ? plan.description
                            : 'Plan detayları yakında.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      priceText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Mevcut Plan',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildFeatureRows(context, plan),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureRows(BuildContext context, PlanOption plan) {
    final theme = Theme.of(context);
    final features = <String>[];
    if (plan.quota != null && plan.quota! > 0) {
      features.add('${plan.quota} tarama hakkı');
    }
    if (plan.period.isNotEmpty) {
      features.add('Yenileme periyodu: ${_prettyPeriod(plan.period)}');
    }
    if (features.isEmpty && plan.description.isNotEmpty) {
      features.add(plan.description);
    } else if (features.isEmpty) {
      features.add('Plan avantajları yakında sunulacak.');
    }

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  String _prettyPeriod(String raw) {
    switch (raw.toLowerCase()) {
      case 'monthly':
      case 'month':
      case 'mo':
        return 'Aylık';
      case 'weekly':
      case 'week':
        return 'Haftalık';
      case 'daily':
      case 'day':
        return 'Günlük';
      case 'yearly':
      case 'annual':
      case 'annually':
      case 'yr':
      case 'year':
        return 'Yıllık';
      case 'once':
      case 'one_time':
      case 'single':
        return 'Tek seferlik';
      default:
        return raw;
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    this.details,
    required this.onRetry,
  });

  final String message;
  final String? details;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
