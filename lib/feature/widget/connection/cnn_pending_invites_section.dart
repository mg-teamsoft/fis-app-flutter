part of '../../page/connection_page.dart';

class _CnnPendingInvitesSection extends StatelessWidget {
  const _CnnPendingInvitesSection({
    required this.pendingInvites,
    required this.isPendingLoading,
    required this.onAccept,
  });

  final List<ContactInviteDto> pendingInvites;
  final bool isPendingLoading;
  final Future<void> Function(String) onAccept;

  @override
  Widget build(BuildContext context) {
    if (isPendingLoading) {
      return const Padding(
        padding: ThemePadding.verticalSymmetricLarge(),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (pendingInvites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pendingInvites.map((invite) {
        return _CnnPendingInviteCard(
          invite: invite,
          onAccept: onAccept,
        );
      }).toList(),
    );
  }
}

class _CnnPendingInviteCard extends StatefulWidget {
  const _CnnPendingInviteCard({
    required this.invite,
    required this.onAccept,
  });

  final ContactInviteDto invite;
  final Future<void> Function(String) onAccept;

  @override
  State<_CnnPendingInviteCard> createState() => _CnnPendingInviteCardState();
}

class _CnnPendingInviteCardState extends State<_CnnPendingInviteCard> {
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onAccept(widget.invite.id);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inviterName = widget.invite.inviterName?.trim().isNotEmpty == true 
      ? widget.invite.inviterName 
      : (widget.invite.inviterEmail?.trim().isNotEmpty == true 
        ? widget.invite.inviterEmail 
        : 'Bir kullanıcı');

    return Container(
      margin: const ThemePadding.marginBottom16(),
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.theme.warning.withValues(alpha: 0.05),
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.theme.warning.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mark_email_unread_rounded, color: context.theme.warning),
              const SizedBox(width: ThemeSize.spacingS),
              Expanded(
                child: ThemeTypography.titleMedium(
                  context,
                  'Yeni Bir Bağlantı Davetiniz Var',
                  weight: FontWeight.w800,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSize.spacingS),
          ThemeTypography.bodySmall(
            context,
            '$inviterName sizi bağlantı olarak eklemek istiyor. Daveti kabul ederek bağlantı kurabilirsiniz.',
            color: context.colorScheme.outline,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeRadius.circular8,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: ThemeSize.iconMedium,
                      height: ThemeSize.iconMedium,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : ThemeTypography.bodyMedium(
                      context,
                      'Kabul Et',
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
