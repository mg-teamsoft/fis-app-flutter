part of '../../page/connection_page.dart';

class _ConnectionCard extends StatefulWidget {
  const _ConnectionCard({required this.statusLabel, required this.contact});

  final _Contact contact;
  final String Function(String) statusLabel;

  @override
  State<_ConnectionCard> createState() => __ConnectionCardState();
}

class __ConnectionCardState extends State<_ConnectionCard> {
  late bool _isActive;
  late Color _statusColor;
  late Color _cardBorderColor;
  late _Contact _contact;

  @override
  void initState() {
    _isActive = widget.contact.status == 'ACTIVE';
    _statusColor = _isActive ? context.theme.success : context.theme.warning;
    _cardBorderColor =
        _isActive ? context.theme.divider : context.theme.warning;
    _contact = widget.contact;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const ThemePadding.marginBottom12(),
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: _cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: ThemeSize.iconMedium,
                backgroundColor: _contact.baseColor.withValues(alpha: 0.1),
                child: ThemeTypography.bodyLarge(
                  context,
                  _contact.initials,
                  color: _contact.baseColor,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: ThemeSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ThemeTypography.bodyLarge(
                          context,
                          _contact.name,
                          color: context.colorScheme.onSurface,
                          weight: FontWeight.w800,
                        ),
                        const SizedBox(width: ThemeSize.spacingS),
                        Container(
                          padding: const ThemePadding.verticalSymmetricSmall(),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: ThemeRadius.circular12,
                          ),
                          child: ThemeTypography.bodySmall(
                            context,
                            widget.statusLabel(_contact.status),
                            weight: FontWeight.w800,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                    ThemeTypography.bodyMedium(
                      context,
                      _contact.email,
                      color: context.colorScheme.onSurface,
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isActive) ...[
            const SizedBox(height: ThemeSize.spacingM),
            const Divider(height: 1),
            const SizedBox(height: ThemeSize.spacingM),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ThemeTypography.bodySmall(
                        context,
                        'Fişleri Görüntüle',
                        color: context.colorScheme.onSurface,
                      ),
                      Switch(
                        value: _contact.canViewReceipts,
                        onChanged: (v) {
                          setState(() {
                            _contact.canViewReceipts = v;
                          });
                        },
                        thumbColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          return context.colorScheme.surface;
                        }),
                        trackColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return context.colorScheme.primary;
                          }
                          return context.colorScheme.onPrimary;
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          return Colors.transparent;
                        }),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.colorScheme.outline,
                ),
                Expanded(
                  child: Column(
                    children: [
                      ThemeTypography.bodySmall(
                        context,
                        'Dosyaları İndir',
                        color: context.colorScheme.onSurface,
                      ),
                      Switch(
                        value: widget.contact.canDownloadFiles,
                        onChanged: (v) {
                          setState(() {
                            _contact.canDownloadFiles = v;
                          });
                        },
                        thumbColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          return context.colorScheme.surface;
                        }),
                        trackColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return context.colorScheme.primary;
                          }
                          return context.colorScheme.onPrimary;
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          return Colors.transparent;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeSize.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: ThemeTypography.bodyMedium(
                    context,
                    'Erişimi Kaldır',
                    color: context.theme.error,
                    weight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colorScheme.outline,
                    side: BorderSide(color: context.colorScheme.outline),
                  ),
                  child: ThemeTypography.bodyLarge(
                    context,
                    'İptal Et',
                    weight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: ThemeSize.spacingS),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.onSurface,
                    foregroundColor: context.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: ThemeRadius.circular12,
                    ),
                  ),
                  child: ThemeTypography.bodyLarge(
                    context,
                    'Yeniden Gönder',
                    weight: FontWeight.w400,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
