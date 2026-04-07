part of '../page/contact_page.dart';

class _ContactView extends StatelessWidget {
  const _ContactView({
    required this.loadSupervisors,
    required this.loadInvites,
    required this.handleInvite,
    required this.handleResendInvite,
    required this.isInviteLoading,
    required this.isContactsLoading,
    required this.isInvitesLoading,
    required this.isEmailFieldFocused,
    required this.inviteCanViewReceipts,
    required this.inviteCanDownloadFiles,
    required this.tabController,
    required this.mailController,
    required this.mailFocusNode,
    required this.connectionsService,
    required this.resendingInviteIds,
    required this.contacts,
    required this.invites,
    this.contactsError,
    this.invitesError,
  });

  final bool isInviteLoading;
  final bool isContactsLoading;
  final bool isInvitesLoading;
  final bool isEmailFieldFocused;
  final bool inviteCanViewReceipts;
  final bool inviteCanDownloadFiles;
  final TabController tabController;
  final TextEditingController mailController;
  final FocusNode mailFocusNode;
  final ConnectionsService connectionsService;
  final Set<String> resendingInviteIds;
  final String? contactsError;
  final String? invitesError;
  final List<_Contact> contacts;
  final List<ContactInviteDto> invites;
  final Future<void> Function() loadSupervisors;
  final Future<void> Function() loadInvites;
  final Future<void> Function() handleInvite;
  final Future<void> Function(ContactInviteDto) handleResendInvite;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
