part of '../../page/account_settings_page.dart';

class _ActiveSettingsUpdateButton extends StatelessWidget {
  const _ActiveSettingsUpdateButton({
    required this.updatingPlan,
    required this.selectedPlanKey,
    required this.currentPlanKey,
    required this.onUpdatePlan,
  });

  final bool updatingPlan;
  final String? selectedPlanKey;
  final String? currentPlanKey;
  final Future<void> Function() onUpdatePlan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ThemeSize.buttonHeightLarge,
      child: ElevatedButton(
        onPressed: (selectedPlanKey == null ||
                selectedPlanKey == currentPlanKey ||
                updatingPlan)
            ? null
            : onUpdatePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: ThemeRadius.circular12,
          ),
        ),
        child: updatingPlan
            ? SizedBox(
                height: ThemeSize.iconMedium,
                width: ThemeSize.iconMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorScheme.onPrimary,
                ),
              )
            : ThemeTypography.bodyMedium(
                context,
                'Planı Güncelle',
                color: context.colorScheme.onPrimary,
                weight: FontWeight.w700,
              ),
      ),
    );
  }
}
