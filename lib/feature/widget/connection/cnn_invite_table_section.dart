part of '../../page/connection_page.dart';

class _CnnInviteTableSection extends StatelessWidget {
  const _CnnInviteTableSection({
    required this.handleResendInvite,
    required this.resendingInviteIds,
    required this.statusColor,
    required this.formatShortDate,
    required this.isInviteLoading,
    required this.isInvitesLoading,
    required this.invitesError,
    required this.invites,
    required this.loadInvites,
  });

  final bool isInviteLoading;
  final bool isInvitesLoading;
  final String? invitesError;
  final Set<String> resendingInviteIds;
  final Color Function(String) statusColor;
  final String Function(DateTime?) formatShortDate;
  final List<ContactInviteDto> invites;
  final Future<void> Function() loadInvites;
  final Future<void> Function(ContactInviteDto) handleResendInvite;

  @override
  Widget build(BuildContext context) {
    if (isInvitesLoading) {
      return const Padding(
        padding: ThemePadding.verticalSymmetricLarge(),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (invitesError != null) {
      return Container(
        padding: const ThemePadding.all16(),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: ThemeRadius.circular12,
          border: Border.all(color: context.theme.error),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThemeTypography.bodyMedium(context, invitesError!,
                color: context.theme.error),
            const SizedBox(height: ThemeSize.spacingM),
            ElevatedButton(
              onPressed: loadInvites,
              child: ThemeTypography.bodyMedium(
                context,
                'Tekrar Dene',
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (invites.isEmpty) {
      return Container(
        padding: const ThemePadding.all16(),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: ThemeRadius.circular12,
          border: Border.all(color: context.theme.divider),
        ),
        child: ThemeTypography.bodyMedium(
          context,
          'Henüz gönderilmiş davet bulunmuyor.',
          color: context.colorScheme.onSurface,
        ),
      );
    }

    final pendingCount = invites
        .where((invite) => invite.status.toUpperCase() == 'PENDING')
        .length;

    return Column(
      children: [
        _CnnInviteSummaryCard(pendingCount: pendingCount),
        const SizedBox(height: 16),
        ...invites.map(
          (invite) => _CnnInvateCard(
            handleResendInvite: handleResendInvite,
            invite: invite,
            formatShortDate: formatShortDate,
            resendingInviteIds: resendingInviteIds,
            statusColor: statusColor,
          ),
        ),
      ],
    );
  }
}
