part of '../../page/register.dart';

class BodyRegister extends StatelessWidget {
  const BodyRegister(
      {super.key,
      required this.formKey,
      required this.req,
      required this.reqpass,
      required this.usernameController,
      required this.mailController,
      required this.passwordController,
      required this.scrollController,
      required this.state,
      required this.onRegister,
      required this.retryFunction,
      required this.planFuture});

  final GlobalKey formKey;
  final String? Function(String?) req;
  final String? Function(String?) reqpass;
  final TextEditingController usernameController;
  final TextEditingController mailController;
  final TextEditingController passwordController;
  final ScrollController scrollController;
  final ValueNotifier<RegisterPageState> state;
  final Future<void> Function() onRegister;
  final Future<List<PlanOption>> planFuture;
  final void Function() retryFunction;

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.height;
    return SafeArea(
        child: SingleChildScrollView(
            controller: scrollController,
            padding: ThemePadding.all24(),
            child: AutofillGroup(
                child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: ThemeSize.spacingM,
                      children: [
                        SizedBox(height: size * 0.075),
                        _RegisterLogo(),
                        _UsernameTextForm(
                          controller: usernameController,
                          req: req,
                        ),
                        _MailTextForm(controller: mailController, req: req),
                        _PasswordTextForm(
                            controller: passwordController,
                            req: req,
                            onRegister: onRegister),
                        _PlanArea(
                            planFuture: planFuture, retryPlans: retryFunction),
                        _RegisterStateSection(
                            state: state, onRegister: onRegister),
                        SizedBox(height: ThemeSize.spacingXl)
                      ],
                    )))));
  }
}

final class _RegisterStateSection extends StatelessWidget {
  const _RegisterStateSection({required this.state, required this.onRegister});

  final ValueNotifier<RegisterPageState> state;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RegisterPageState>(
      valueListenable: state,
      builder: (context, currentState, _) {
        return Column(
          children: [
            if (currentState.errorMessage.isNotEmpty)
              _RegisterErrorText(message: currentState.errorMessage),
            const SizedBox(height: ThemeSize.spacingL),
            _RegisterButton(
              isLoading: currentState.isLoading,
              onPressed: onRegister,
            ),
            SizedBox(height: ThemeSize.spacingXl),
            _RegisterBackButton()
          ],
        );
      },
    );
  }
}

final class _RegisterLogo extends StatelessWidget {
  const _RegisterLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/icon/RBGAppIcon.png',
        width: ThemeSize.avatarXL, height: ThemeSize.avatarXL);
  }
}

@immutable
final class _UsernameTextForm extends StatelessWidget {
  _UsernameTextForm({required this.controller, required this.req});

  final TextEditingController controller;
  String? Function(String?) req;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Kullanıcı Adı',
        prefixIcon: Icon(Icons.person),
      ),
      textInputAction: TextInputAction.next,
      validator: req,
      autofillHints: const [AutofillHints.username],
    );
  }
}

final class _MailTextForm extends StatelessWidget {
  _MailTextForm({required this.controller, required this.req});

  final TextEditingController controller;
  String? Function(String?) req;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'E-posta',
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: req,
      autofillHints: const [AutofillHints.email],
    );
  }
}

final class _PasswordTextForm extends StatelessWidget {
  _PasswordTextForm(
      {required this.controller, required this.req, required this.onRegister});

  final TextEditingController controller;
  String? Function(String?) req;
  Future<void> Function() onRegister;
  final ValueNotifier<bool> _obscureNotifier = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _obscureNotifier,
        builder: (context, isObscure, child) {
          return TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () =>
                    _obscureNotifier.value = !_obscureNotifier.value,
              ),
            ),
            obscureText: isObscure,
            validator: req,
            onFieldSubmitted: (_) => onRegister(),
            autofillHints: const [AutofillHints.newPassword],
          );
        });
  }
}

final class _PlanArea extends StatelessWidget {
  _PlanArea({
    required this.planFuture,
    required this.retryPlans,
  });
  final Future<List<PlanOption>> planFuture;
  final void Function() retryPlans;
  final ValueNotifier<String?> _selectedNotifier = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
        valueListenable: _selectedNotifier,
        builder: (context, isSelected, child) {
          return FutureBuilder<List<PlanOption>>(
            future: planFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _PlanLoadingState();
              }
              if (snapshot.hasError) {
                return _PlanErrorState(
                  message: 'Planlar yüklenemedi.',
                  details: snapshot.error?.toString(),
                  onRetry: retryPlans,
                );
              }
              final plans = snapshot.data ?? const <PlanOption>[];
              if (plans.isEmpty) {
                return _PlanErrorState(
                  message: 'Görüntülenecek plan bulunamadı.',
                  onRetry: retryPlans,
                );
              }

              if (_selectedNotifier.value == null && plans.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _selectedNotifier.value = plans.first.planKey;
                });
              }

              final effectiveSelectedKey =
                  _selectedNotifier.value ?? plans.first.planKey;

              final tiles = <Widget>[];
              for (var i = 0; i < plans.length; i++) {
                final plan = plans[i];
                tiles.add(
                  _PlanTile(
                    plan: plan,
                    selected: plan.planKey == effectiveSelectedKey,
                    onTap: () => _selectedNotifier.value = plan.planKey,
                  ),
                );
                if (i < plans.length - 1) {
                  tiles.add(const SizedBox(height: 12));
                }
              }
              return Column(children: tiles);
            },
          );
        });
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
    final borderColor = selected
        ? context.colorScheme.outline
        : context.colorScheme.outlineVariant;
    final backgroundColor = selected
        ? context.colorScheme.surface
        : context.colorScheme.primary.withValues(alpha: 0.075);
    final priceText = plan.billingCycle.isNotEmpty
        ? '${plan.priceLabel}/${plan.billingCycle}'
        : plan.priceLabel;
    final badgeText = (plan.badge != null && plan.badge!.trim().isNotEmpty)
        ? plan.badge!.trim()
        : (plan.isPopular ? 'Popüler' : null);
    final badgeBackground = selected
        ? context.colorScheme.primary
        : context.colorScheme.secondaryContainer;
    final badgeForeground = selected
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSecondaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: ThemePadding.all16(),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          borderRadius: ThemeRadius.circular16,
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
                        style: ThemeTypography.titleMedium(context, '')
                            .style
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      priceText,
                      style: ThemeTypography.titleMedium(context, '')
                          .style
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (selected)
                      Padding(
                        padding: ThemePadding.all10(),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: context.colorScheme.primary,
                          child: Icon(
                            Icons.check,
                            color: context.colorScheme.onSecondary,
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: ThemeSize.spacingS),
                Text(
                  plan.description.isNotEmpty
                      ? plan.description
                      : 'Plan detayları yakında.',
                  style:
                      ThemeTypography.bodyMedium(context, '').style?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
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
                    style:
                        ThemeTypography.labelSmall(context, '').style?.copyWith(
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
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: ThemePadding.all16(),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: ThemeRadius.circular16,
              border: Border.all(color: context.colorScheme.outlineVariant),
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
    return Container(
      width: double.infinity,
      padding: ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular16,
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline,
                  color: context.colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: ThemeTypography.bodySmall(context, '').style?.copyWith(
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
              style: ThemeTypography.bodySmall(context, '').style?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: ThemeSize.spacingS),
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

final class _RegisterErrorText extends StatelessWidget {
  const _RegisterErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ThemeTypography.bodySmall(
      context,
      message,
      color: context.colorScheme.error,
    );
  }
}

final class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: ThemeRadius.circular8),
            backgroundColor: context.appTheme.brandSecondary,
            padding: ThemePadding.all10(),
            minimumSize: const Size(120, 40)),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: ThemeSize.spacingL,
                children: [
                  Icon(
                    Icons.login,
                    color: context.colorScheme.onSecondary,
                    size: ThemeSize.iconLarge,
                  ),
                  ThemeTypography.h4(context, 'Kayıt Ol',
                      color: context.colorScheme.onSecondary)
                ],
              ),
      ),
    );
  }
}

final class _RegisterBackButton extends StatelessWidget {
  const _RegisterBackButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: ThemeTypography.titleLarge(context, 'Giriş Ekranına Dön',
            color: context.colorScheme.secondary));
  }
}
