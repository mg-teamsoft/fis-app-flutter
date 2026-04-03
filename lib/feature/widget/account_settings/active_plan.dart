part of '../../page/account_settings.dart';

class _AccountSettingsActivePlan extends StatefulWidget {
  const _AccountSettingsActivePlan({
    required this.updatingPlan,
    required this.plans,
    required this.activePlan,
    required this.selectedPlanKey,
    required this.onBuyAdditional,
    required this.availablePlanBackground,
    required this.availablePlanBorder,
  });

  final bool updatingPlan;
  final List<PlanOption> plans;
  final PlanOption? activePlan;
  final String? selectedPlanKey;
  final Future<void> Function() onBuyAdditional;
  final Color Function(int) availablePlanBackground;
  final Color Function(int) availablePlanBorder;

  @override
  State<_AccountSettingsActivePlan> createState() =>
      __AccountSettingsActivePlanState();
}

class __AccountSettingsActivePlanState
    extends State<_AccountSettingsActivePlan> {
  String? selectedPlanKey;

  @override
  void initState() {
    super.initState();
    selectedPlanKey = widget.selectedPlanKey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AccountSettingsSectionTitle(text: 'Aktif Plan'),
        const SizedBox(height: 12),
        if (widget.activePlan != null)
          _ActiveSettingsPlanCard(
            plan: widget.activePlan!,
            onBuyAdditional:
                widget.updatingPlan ? null : widget.onBuyAdditional,
          )
        else
          const _AccountSettingsEmptyPlanCard(),
        const SizedBox(height: 24),
        const _AccountSettingsSectionTitle(text: 'Mevcut Planlar'),
        const SizedBox(height: 12),
        if (widget.plans.isEmpty)
          const _AccountSettingsEmptyPlanCard()
        else
          ...widget.plans.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final plan = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AccountSettingsAvailablePlanTile(
                  plan: plan,
                  selected: selectedPlanKey == plan.planKey,
                  backgroundColor: widget.availablePlanBackground(index),
                  borderColor: widget.availablePlanBorder(index),
                  onTap: () => setState(() => selectedPlanKey = plan.planKey),
                ),
              );
            },
          ),
      ],
    );
  }
}
