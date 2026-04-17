part of '../page/about_page.dart';

class _AboutView extends StatelessWidget {
  const _AboutView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const ThemePadding.horizontalSymmetric(),
      child: Column(
        children: [
          // App name
          ThemeTypography.h4(
            context,
            'My Fiş App',
            color: context.colorScheme.onSurface,
          ),
          const SizedBox(height: ThemeSize.spacingL),
          // App icon in circle
          const CircleAvatar(
            radius: ThemeSize.avatarXL,
            backgroundImage: AssetImage('assets/icon/AppImage.jpg'),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          ThemeTypography.bodyMedium(
            context,
            'Küçük işletmeniz için fişlerinizi zahmetsizce taratın, kaydedin ve gönderin. '
            'Uygulamamız, sorunsuz, hızlı fişlerinizi dijital ortama almanıza yardımcı olmak için tasarlanmıştır.',
            textAlign: TextAlign.center,
            color: context.colorScheme.onSurface,
          ),
          const SizedBox(height: ThemeSize.spacingL),

          // Feature list
          const _AboutFeatureTile(
            icon: Icons.description,
            text:
                'Fişlerinizi taratın, kaydedin, doğrulayın ve kendiniz yönetin.',
          ),
          const _AboutFeatureTile(
            icon: Icons.payments,
            text: 'Ödemelerinizi takip edin ve muhasebeciniz ile paylaşın.',
          ),
          const _AboutFeatureTile(
            icon: Icons.bar_chart,
            text: 'Anlamlı finansal takip raporları oluşturun.',
          ),
          const _AboutFeatureTile(
            icon: Icons.security,
            text:
                'Resimlerinizi ve dosyalarınızı güvenli bir şekilde saklayın.',
          ),
        ],
      ),
    );
  }
}
