part of '../../page/account_settings_page.dart';

class _AccountSettingsDetailsCard extends StatelessWidget {
  const _AccountSettingsDetailsCard({
    required this.user,
    required this.resendingVerification,
    required this.onResendVerification,
  });

  final UserProfile user;
  final bool resendingVerification;
  final VoidCallback onResendVerification;

  @override
  Widget build(BuildContext context) {
    final createdAt = user.createdAt;
    final createdAtLabel = createdAt != null
        ? DateFormat('d MMMM yyyy', 'tr_TR').format(createdAt)
        : '-';

    return Container(
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.theme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeTypography.bodyLarge(
            context,
            'Kullanıcı Adı',
            color: context.theme.divider,
          ),
          const SizedBox(height: ThemeSize.spacingXs),
          ThemeTypography.bodyLarge(
            context,
            user.userName,
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          Divider(height: 1, color: context.theme.divider),
          const SizedBox(height: ThemeSize.spacingM),
          ThemeTypography.bodyLarge(
            context,
            'E-posta',
            color: context.colorScheme.outline,
          ),
          const SizedBox(height: ThemeSize.spacingXs),
          ThemeTypography.bodyLarge(
            context,
            user.email,
            color: context.colorScheme.onSurface,
            weight: FontWeight.w500,
          ),
          if (!user.emailVerified) ...[
            const SizedBox(height: ThemeSize.spacingM),
            Container(
              padding: const ThemePadding.horizontalSymmetricMedium(),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainer,
                borderRadius: ThemeRadius.circular12,
                border: Border.all(color: context.theme.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: context.theme.error,
                    size: ThemeSize.iconSmall,
                  ),
                  const SizedBox(width: ThemeSize.spacingXs),
                  Expanded(
                    child: ThemeTypography.bodyLarge(
                      context,
                      'E-posta doğrulanmadı',
                      color: context.theme.error,
                      weight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        resendingVerification ? null : onResendVerification,
                    child: resendingVerification
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ThemeTypography.bodyMedium(
                            context,
                            'Tekrar Gönder',
                            color: context.colorScheme.primary,
                          ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: ThemeSize.spacingM),
          Divider(height: 1, color: context.colorScheme.outline),
          const SizedBox(height: ThemeSize.spacingM),
          ThemeTypography.bodyLarge(
            context,
            'Hesap Oluşturma',
            color: context.colorScheme.outline,
          ),
          const SizedBox(height: ThemeSize.spacingXs),
          ThemeTypography.bodyLarge(
            context,
            createdAtLabel,
            color: context.colorScheme.onSurface,
            weight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
