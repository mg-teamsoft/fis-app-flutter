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
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (invitesError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invitesError!,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadInvites,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (invites.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          'Henüz gönderilmiş davet bulunmuyor.',
          style: TextStyle(color: Colors.grey.shade700),
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
