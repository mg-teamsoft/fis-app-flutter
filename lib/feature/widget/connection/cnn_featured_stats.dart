part of '../../page/connection_page.dart';

class _CnnFeaturedStats extends StatelessWidget {
  const _CnnFeaturedStats({
    required this.contacts,
  });

  final List<_Contact> contacts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: ThemeRadius.circular12,
          ),
          child: Stack(
            children: [
              Positioned(
                right: 10,
                bottom: -20,
                child: Icon(
                  Icons.groups,
                  size: ThemeSize.avatarLarge,
                  color: context.colorScheme.surface.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const ThemePadding.all24(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemeTypography.bodySmall(
                      context,
                      'EKİP VERİMLİLİĞİ',
                      color: context.colorScheme.surface.withValues(alpha: 0.8),
                      weight: FontWeight.w800,
                    ),
                    const SizedBox(height: 12),
                    ThemeTypography.titleLarge(
                      context,
                      'Finansal danışmanlarınızla\nsorunsuz şekilde iş birliği yapın.',
                      color: context.colorScheme.surface,
                      weight: FontWeight.w800,
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: false, // Buraya değişkenini bağlayabilirsin
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.surface,
                          foregroundColor: context.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: ThemeRadius.circular8,
                          ),
                          padding: const ThemePadding.verticalSymmetricMedium(),
                        ),
                        child: ThemeTypography.bodyLarge(
                          context,
                          'Daha Fazla Bilgi',
                          color: context.colorScheme.primary,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ThemeSize.spacingM),
        Container(
          width: double.infinity,
          padding: const ThemePadding.all24(),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: ThemeRadius.circular12,
            border: Border.all(color: context.theme.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const ThemePadding.all10(),
                decoration: BoxDecoration(
                  color: context.theme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  color: context.theme.success,
                  size: ThemeSize.iconLarge,
                ),
              ),
              const SizedBox(height: ThemeSize.spacingM),
              ThemeTypography.h4(
                context,
                '${contacts.length}',
                color: context.colorScheme.onSurface,
                weight: FontWeight.w800,
              ),
              const SizedBox(height: ThemeSize.spacingXs),
              ThemeTypography.bodyMedium(
                context,
                'Aktif Danışmanlar',
                color: context.colorScheme.onSurface,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
