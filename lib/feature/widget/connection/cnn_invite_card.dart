part of '../../page/connection_page.dart';

class _CnnInvateCard extends StatefulWidget {
  const _CnnInvateCard({
    required this.handleResendInvite,
    required this.formatShortDate,
    required this.resendingInviteIds,
    required this.invite,
    required this.statusColor,
  });

  final ContactInviteDto invite;
  final Set<String> resendingInviteIds;
  final Color Function(String) statusColor;
  final String Function(DateTime?) formatShortDate;
  final Future<void> Function(ContactInviteDto) handleResendInvite;

  @override
  State<_CnnInvateCard> createState() => __CnnInvateCardState();
}

class __CnnInvateCardState extends State<_CnnInvateCard> {
  late Color _statusColor;
  late bool _isPending;
  late bool _isExpired;
  late bool _hasResponded;
  late bool _isResending;

  @override
  void initState() {
    _statusColor = widget.statusColor(widget.invite.status);
    _isPending = widget.invite.status.toUpperCase() == 'PENDING';
    _isExpired = widget.invite.status.toUpperCase() == 'EXPIRED';
    _hasResponded = widget.invite.respondedAt != null;
    _isResending = widget.resendingInviteIds.contains(widget.invite.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const ThemePadding.all15(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeTypography.labelSmall(
            context,
            'DAVET EDİLEN E-POSTA',
            color: context.colorScheme.onSurface,
          ),
          const SizedBox(height: 6),
          ThemeTypography.titleMedium(
            context,
            widget.invite.inviteeEmail.isEmpty
                ? '-'
                : widget.invite.inviteeEmail,
            weight: FontWeight.w800,
            color: context.colorScheme.onSurface,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget
                  .statusColor(widget.invite.status)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.invite.status.toUpperCase(),
              style: TextStyle(
                color: _statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CnnInviteMetaItem(
                  label: 'OLUŞTURULMA',
                  value: widget.formatShortDate(widget.invite.createdAt),
                  valueColor: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CnnInviteMetaItem(
                  label: _hasResponded ? 'YANIT TARİHİ' : 'BİTİŞ TARİHİ',
                  value: widget.formatShortDate(
                    _hasResponded
                        ? widget.invite.respondedAt
                        : widget.invite.expiresAt,
                  ),
                  valueColor: !_hasResponded && _isExpired
                      ? const Color(0xFFF97066)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ThemeTypography.labelSmall(
            context,
            _isPending ? 'VERİLEN YETKİLER' : 'TALEP EDİLEN YETKİLER',
            color: context.colorScheme.surface,
            weight: FontWeight.w800,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.invite.permissions.isEmpty
                ? [
                    const _CnnPermissionChip(
                      label: '-',
                      icon: null,
                    ),
                  ]
                : widget.invite.permissions
                    .map(
                      (permission) => _CnnPermissionChip(
                        label: _permissionLabel(permission),
                        icon: _permissionIcon(permission),
                      ),
                    )
                    .toList(),
          ),
          if (_isExpired || _isPending) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isExpired && !_isResending
                    ? () => widget.handleResendInvite(widget.invite)
                    : null,
                icon: Icon(
                  _isResending
                      ? Icons.hourglass_top
                      : _isExpired
                          ? Icons.refresh
                          : Icons.schedule,
                  size: 16,
                  color: const Color(0xFF2E90FA),
                ),
                label: ThemeTypography.bodyLarge(
                  context,
                  _isExpired
                      ? (_isResending
                          ? 'Yeniden Gönderiliyor...'
                          : 'Daveti Yeniden Gönder')
                      : 'Yanıt Bekleniyor',
                  color: context.colorScheme.primary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _permissionLabel(String permission) {
    if (permission == ContactPermission.viewReceipts.apiValue) {
      return 'Fişleri Görüntüle';
    }
    if (permission == ContactPermission.downloadFiles.apiValue) {
      return 'Dosyaları İndir';
    }
    return permission.replaceAll('_', ' ');
  }

  IconData _permissionIcon(String permission) {
    if (permission == ContactPermission.viewReceipts.apiValue) {
      return Icons.receipt_long_outlined;
    }
    if (permission == ContactPermission.downloadFiles.apiValue) {
      return Icons.download_outlined;
    }
    return Icons.shield_outlined;
  }
}
