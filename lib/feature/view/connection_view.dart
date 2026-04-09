part of '../page/connection_page.dart';

class _ConnectionView extends StatelessWidget {
  const _ConnectionView({
    required this.handleInvite,
    required this.loadSupervisors,
    required this.loadInvites,
    required this.handleResendInvite,
    required this.mapContact,
    required this.buildInitials,
    required this.statusColor,
    required this.statusLabel,
    required this.formatShortDate,
    required this.tabController,
    required this.mailController,
    required this.mailFocusNode,
    required this.connectionsService,
    required this.isInviteLoading,
    required this.isContactsLoading,
    required this.isInvitesLoading,
    required this.isEmailFieldFocused,
    required this.inviteCanViewReceipts,
    required this.inviteCanDownloadFiles,
    required this.resendingInviteIds,
    required this.contactsError,
    required this.invitesError,
    required this.contacts,
    required this.invites,
  });

  final TabController tabController;
  final TextEditingController mailController;
  final FocusNode mailFocusNode;
  final ConnectionsService connectionsService;
  final bool isInviteLoading;
  final bool isContactsLoading;
  final bool isInvitesLoading;
  final bool isEmailFieldFocused;
  final bool inviteCanViewReceipts;
  final bool inviteCanDownloadFiles;
  final Set<String> resendingInviteIds;
  final String? contactsError;
  final String? invitesError;
  final List<_Contact> contacts;
  final List<ContactInviteDto> invites;

  final Future<void> Function() handleInvite;
  final Future<void> Function() loadSupervisors;
  final Future<void> Function() loadInvites;
  final Future<void> Function(ContactInviteDto) handleResendInvite;
  final _Contact Function(SupervisorContactDto) mapContact;
  final String Function(String, String) buildInitials;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final String Function(DateTime?) formatShortDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        TabBar(
          controller: tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(text: 'Mali Müşavirler'),
            Tab(text: 'Davetler'),
          ],
        ),
        const SizedBox(height: 16),
        // Expanded body for scrollable content
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _CnnInviteSection(
                    handleInvite: handleInvite,
                    isInviteLoading: isInviteLoading,
                    isEmailFieldFocused: isEmailFieldFocused,
                    inviteCanViewReceipts: inviteCanViewReceipts,
                    inviteCanDownloadFiles: inviteCanDownloadFiles,
                    emailController: mailController,
                    emailFocusNode: mailFocusNode,
                  ),
                  const SizedBox(height: 16),
                  _CnnContactsSection(
                    statusLabel: statusLabel,
                    isContactsLoading: isContactsLoading,
                    contacts: contacts,
                    contactsError: contactsError,
                    onRetry: loadSupervisors,
                  ),
                  const SizedBox(height: 24),
                  _CnnFeaturedStats(contacts: contacts),
                ],
              ),
              ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _CnnInviteTableSection(
                    handleResendInvite: handleResendInvite,
                    isInviteLoading: isInviteLoading,
                    isInvitesLoading: isInvitesLoading,
                    invitesError: invitesError,
                    invites: invites,
                    loadInvites: loadInvites,
                    resendingInviteIds: resendingInviteIds,
                    statusColor: statusColor,
                    formatShortDate: formatShortDate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
