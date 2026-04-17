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
    _statusColor = _isActive ? Colors.green : Colors.orange;
    _cardBorderColor =
        _isActive ? Colors.grey.shade300 : Colors.orange.shade200;
    _contact = widget.contact;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                radius: 24,
                backgroundColor: _contact.baseColor.withValues(alpha: 0.1),
                child: ThemeTypography.bodyLarge(
                  context,
                  _contact.initials,
                  color: _contact.baseColor,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
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
                          return Colors.white;
                        }),
                        trackColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF2563EB);
                          }
                          return const Color(0xFFE2E8F0);
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
                  color: Colors.grey.shade200,
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
                          return Colors.white;
                        }),
                        trackColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF2563EB);
                          }
                          return const Color(0xFFE2E8F0);
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
            const SizedBox(height: 8),
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
                    foregroundColor: Colors.grey.shade800,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: ThemeTypography.bodyLarge(
                    context,
                    'İptal Et',
                    weight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
