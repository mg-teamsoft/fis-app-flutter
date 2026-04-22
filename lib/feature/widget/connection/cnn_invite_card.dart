part of '../../page/connection_page.dart';

class _CnnInvateCard extends StatefulWidget {
  const _CnnInvateCard({
    required this.handleResendInvite,
    required this.formatShortDate,
    required this.resendingInviteIds,
    required this.invite,
    required this.statusText,
    required this.statusColor,
  });

  final ContactInviteDto invite;
  final Set<String> resendingInviteIds;
  final Color Function(String) statusColor;
  final String Function(DateTime?) formatShortDate;
  final String Function(String) statusText;
  final Future<void> Function(ContactInviteDto) handleResendInvite;

  @override
  State<_CnnInvateCard> createState() => __CnnInvateCardState();
}

class __CnnInvateCardState extends State<_CnnInvateCard> {
  late Color _statusColor;
  late String _statusText;
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
      margin: const ThemePadding.marginBottom15(),
      padding: const ThemePadding.all15(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.theme.divider),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.03),
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
            padding: ThemePadding.horizontalSymmetricFree(12),
            decoration: BoxDecoration(
              color: widget.statusColor(widget.invite.status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ThemeTypography.bodySmall(
              context,
              widget.statusText(widget.invite.status),
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: ThemeSize.spacingM),
          Row(
            children: [
              Expanded(
                child: _CnnInviteMetaItem(
                  label: 'OLUŞTURULMA',
                  value: widget.formatShortDate(widget.invite.createdAt),
                  valueColor: null,
                ),
              ),
              const SizedBox(width: ThemeSize.spacingM),
              Expanded(
                child: _CnnInviteMetaItem(
                  label: _hasResponded ? 'YANIT TARİHİ' : 'BİTİŞ TARİHİ',
                  value: widget.formatShortDate(
                    _hasResponded
                        ? widget.invite.respondedAt
                        : widget.invite.expiresAt,
                  ),
                  valueColor:
                      !_hasResponded && _isExpired ? context.theme.error : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSize.spacingM),
          ThemeTypography.labelSmall(
            context,
            _isPending ? 'VERİLEN YETKİLER' : 'TALEP EDİLEN YETKİLER',
            color: context.colorScheme.onSurface,
            weight: FontWeight.w800,
          ),
          const SizedBox(height: ThemeSize.spacingXs),
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
            const SizedBox(height: ThemeSize.spacingM),
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
                  color: context.colorScheme.primary,
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
