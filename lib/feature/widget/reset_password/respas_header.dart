part of '../../page/reset_password_page.dart';

final class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader({required this.enter});
  final bool enter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (enter)
          ThemeTypography.h4(
            context,
            'Şifre Yenileme',
            color: context.colorScheme.onSurface,
            weight: FontWeight.w700,
          )
        else
          const SizedBox.shrink(),
        const SizedBox(height: ThemeSize.spacingXXXl),
        if (enter) const SizedBox.shrink() else const _ResetPasswordLogo(),
        const SizedBox(height: ThemeSize.spacingS),
        ThemeTypography.bodyMedium(
          context,
          enter
              ? 'Yeni şifrenizi giriniz.'
              : 'E-postadaki bağlantıyı açarak geldiniz. Yeni şifrenizi belirleyin.',
          color: context.colorScheme.onSurface,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
