part of '../page/account_settings_page.dart';

class _AccountSettingsView extends StatelessWidget {
  const _AccountSettingsView({
    super.key,
    required this.scrollController,
    required this.loading,
    required this.updatingPlan,
    required this.resendingVerification,
    required this.error,
    required this.transactionError,
    required this.currentPlanKey,
    required this.selectedPlanKey,
    required this.plans,
    required this.user,
    required this.transactions,
    required this.activePlan,
    required this.navSpacer,
    required this.loadAll,
    required this.onRefresh,
    required this.onResendVerification,
    required this.onBuyAdditional,
    required this.onPlanSelected,
    required this.onUpdatePlan,
    required this.availablePlanBackground,
    required this.availablePlanBorder,
    required this.onResetPassword,
  });

  final ScrollController scrollController;
  final bool loading;
  final bool updatingPlan;
  final bool resendingVerification;
  final String? error;
  final String? transactionError;
  final String? currentPlanKey;
  final String? selectedPlanKey;
  final List<PlanOption> plans;
  final UserProfile? user;
  final List<PurchaseTransaction> transactions;
  final PlanOption? activePlan;
  final double navSpacer;

  final Future<void> Function() loadAll;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onResendVerification;
  final Future<void> Function(PlanOption plan)? onBuyAdditional;
  final void Function(String planKey) onPlanSelected;
  final Future<void> Function() onUpdatePlan;
  final Color Function(int) availablePlanBackground;
  final Color Function(int) availablePlanBorder;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _ErrorView(
        message: 'Hesap ayarları yüklenemedi.',
        details: error,
        onRetry: loadAll,
      );
    }

    if (user == null) {
      return _ErrorView(
        message: 'Kullanıcı profili bulunamadı.',
        onRetry: loadAll,
      );
    }

    final plansWithInterval = plans
        .where((plan) =>
            plan.productType != 'consumable' && plan.planKey != 'FREE')
        .toList();

    final additionalPlans =
        plans.where((plan) => plan.planKey == 'ADDITIONAL_100').toList();
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const ThemePadding.all20(),
        children: [
          const _AccountSettingsSectionTitle(text: 'Hesap Detayları'),
          const SizedBox(height: ThemeSize.spacingM),
          _AccountSettingsDetailsCard(
            user: user!,
            resendingVerification: resendingVerification,
            onResendVerification: onResendVerification,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          _AccountSettingsResetPasswordButton(onResetPassword: onResetPassword),
          const SizedBox(height: ThemeSize.spacingL),
          _AccountSettingsActivePlan(
            updatingPlan: updatingPlan,
            plans: plansWithInterval,
            additionalPlans: additionalPlans,
            activePlan: activePlan,
            selectedPlanKey: selectedPlanKey,
            onBuyAdditional: onBuyAdditional,
            onPlanSelected: onPlanSelected,
            availablePlanBackground: availablePlanBackground,
            availablePlanBorder: availablePlanBorder,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          if (plansWithInterval.isNotEmpty)
            _ActiveSettingsUpdateButton(
              updatingPlan: updatingPlan,
              selectedPlanKey: selectedPlanKey,
              currentPlanKey: currentPlanKey,
              onUpdatePlan: onUpdatePlan,
            ),
          const SizedBox(height: ThemeSize.spacingL),
          const _AccountSettingsSectionTitle(text: 'Ödeme Detayları'),
          const SizedBox(height: ThemeSize.spacingM),
          _AccountSettingsPaymentDetailsTable(
            transactions: transactions,
            error: transactionError,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          Text(
            'Plan değişiklikleri hemen uygulanır. Mevcut fatura dönemindeki kullanılmayan kota için iade yapılmaz.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.outline,
            ),
          ),
          const SizedBox(height: ThemeSize.spacingM),
          SizedBox(height: navSpacer),
        ],
      ),
    );
  }
}
