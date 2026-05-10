part of '../../page/settings_page.dart';

final class _SettingsSaveButton extends StatelessWidget {
  const _SettingsSaveButton({
    required this.saving,
    required this.hasChanges,
    required this.saveSettings,
  });

  final bool saving;
  final bool hasChanges;
  final Future<void> Function() saveSettings;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (saving || !hasChanges) ? null : saveSettings,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colorScheme.primary,
        disabledBackgroundColor: context.colorScheme.outline,
        foregroundColor: context.colorScheme.onPrimary,
        disabledForegroundColor: context.colorScheme.onSurface,
        minimumSize: const Size(0, ThemeSize.buttonHeightMedium),
        padding: const ThemePadding.verticalSymmetricMedium(),
        shape: RoundedRectangleBorder(
          borderRadius: ThemeRadius.circular12,
        ),
      ),
      child: saving
          ? SizedBox(
              height: ThemeSize.iconMedium,
              width: ThemeSize.iconMedium,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colorScheme.onSecondary,
                ),
              ),
            )
          : ThemeTypography.bodyLarge(
              context,
              'Değişiklikleri Kaydet',
              weight: FontWeight.w600,
              color: context.colorScheme.onPrimary,
            ),
    );
  }
}
