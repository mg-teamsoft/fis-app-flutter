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
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 10,
                bottom: -20,
                child: Icon(
                  Icons.groups,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24), // İstediğin iç boşluk buraya
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
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: ThemeTypography.bodyLarge(
                        context,
                        'Daha Fazla Bilgi',
                        color: context.colorScheme.primary,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  color: Colors.green.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${contacts.length}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
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
