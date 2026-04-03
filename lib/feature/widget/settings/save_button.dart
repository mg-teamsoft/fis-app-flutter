part of '../../page/settings.dart';

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
        foregroundColor: context.colorScheme.surface,
        disabledForegroundColor: context.colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
          : Text(
              'Değişiklikleri Kaydet',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
