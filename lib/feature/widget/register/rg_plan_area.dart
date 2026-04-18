part of '../../page/register_page.dart';

final class _RegisterPlanArea extends StatefulWidget {
  const _RegisterPlanArea({
    required this.plansFuture,
    required this.retryPlans,
    required this.initialSelectedPlanKey,
    required this.onPlanSelected,
  });

  final String? initialSelectedPlanKey;
  final Future<List<PlanOption>> plansFuture;
  final VoidCallback retryPlans;
  final ValueChanged<String> onPlanSelected;

  @override
  State<_RegisterPlanArea> createState() => __RegisterPlanAreaState();
}

class __RegisterPlanAreaState extends State<_RegisterPlanArea> {
  String? _selectedPlanKey;

  @override
  void initState() {
    super.initState();
    _selectedPlanKey = widget.initialSelectedPlanKey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ThemeTypography.titleMedium(
            context,
            'Plan Seçimi',
            weight: FontWeight.w600,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<PlanOption>>(
          future: widget.plansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _PlanLoadingState();
            }
            if (snapshot.hasError) {
              return _PlanErrorState(
                message: 'Planlar yüklenemedi.',
                details: snapshot.error?.toString(),
                onRetry: widget.retryPlans,
              );
            }
            final plans = (snapshot.data ?? const <PlanOption>[])
                .where((plan) => plan.isFreePlan)
                .toList();
            if (plans.isEmpty) {
              return _PlanErrorState(
                message: 'Görüntülenecek ücretsiz plan bulunamadı.',
                onRetry: widget.retryPlans,
              );
            }

            final hasSelectedPlan = plans.any(
              (plan) => plan.planKey == _selectedPlanKey,
            );

            if (!hasSelectedPlan) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _selectedPlanKey = plans.first.planKey);
                widget.onPlanSelected(plans.first.planKey);
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
                  onTap: () {
                    setState(() => _selectedPlanKey = plan.planKey);
                    widget.onPlanSelected(plan.planKey);
                  },
                ),
              );
              if (i < plans.length - 1) {
                tiles.add(const SizedBox(height: 12));
              }
            }
            return Column(children: tiles);
          },
        ),
      ],
    );
  }
}
