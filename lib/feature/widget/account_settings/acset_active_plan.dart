part of '../../page/account_settings_page.dart';

class _AccountSettingsActivePlan extends StatelessWidget {
  const _AccountSettingsActivePlan({
    required this.updatingPlan,
    required this.plans,
    required this.additionalPlans,
    required this.activePlan,
    required this.selectedPlanKey,
    required this.onBuyAdditional,
    required this.onPlanSelected,
    required this.availablePlanBackground,
    required this.availablePlanBorder,
  });

  final bool updatingPlan;
  final List<PlanOption> plans;
  final List<PlanOption> additionalPlans;
  final PlanOption? activePlan;
  final String? selectedPlanKey;
  final Future<void> Function(PlanOption plan)? onBuyAdditional;
  final void Function(String planKey) onPlanSelected;
  final Color Function(int) availablePlanBackground;
  final Color Function(int) availablePlanBorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AccountSettingsSectionTitle(text: 'Aktif Plan'),
        const SizedBox(height: 12),
        if (activePlan != null)
          _ActiveSettingsPlanCard(
            plan: activePlan!,
            onBuyAdditional:
                updatingPlan ? null : (plan) => onBuyAdditional!(plan),
            additionalPlans: additionalPlans,
          )
        else
          const _AccountSettingsEmptyPlanCard(),
        if (plans.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _AccountSettingsSectionTitle(text: 'Mevcut Planlar'),
          const SizedBox(height: 12),
          ...plans.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final plan = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AccountSettingsAvailablePlanTile(
                  plan: plan,
                  selected: selectedPlanKey == plan.planKey,
                  backgroundColor: availablePlanBackground(index),
                  borderColor: availablePlanBorder(index),
                  onTap: () => onPlanSelected(plan.planKey),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
