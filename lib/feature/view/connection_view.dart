part of '../page/connection_page.dart';

class _ConnectionView extends StatelessWidget {
  const _ConnectionView({
    required this.handleInvite,
    required this.loadSupervisors,
    required this.loadInvites,
    required this.handleResendInvite,
    required this.handleRemoveSupervisorAccess,
    required this.mapContact,
    required this.buildInitials,
    required this.statusColor,
    required this.statusLabel,
    required this.formatShortDate,
    required this.tabController,
    required this.mailController,
    required this.statusText,
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
    required this.pendingInvites,
    required this.isPendingInvitesLoading,
    required this.handleAcceptInvite,
    required this.customers,
    required this.isCustomersLoading,
    required this.customersError,
    required this.loadCustomers,
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
  final String Function(String) statusText;
  final List<ContactInviteDto> invites;
  final List<ContactInviteDto> pendingInvites;
  final bool isPendingInvitesLoading;

  final Future<void> Function(String) handleAcceptInvite;
  final List<_Customer> customers;
  final bool isCustomersLoading;
  final String? customersError;
  final Future<void> Function() loadCustomers;
  final Future<void> Function() handleInvite;
  final Future<void> Function() loadSupervisors;
  final Future<void> Function() loadInvites;
  final Future<void> Function(ContactInviteDto) handleResendInvite;
  final Future<void> Function(_Contact) handleRemoveSupervisorAccess;
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
        // Header
        const SizedBox(height: ThemeSize.spacingXs),
        Align(
          child: ThemeTypography.h4(
            context,
            'Kişiler',
            weight: FontWeight.w900,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: ThemeSize.spacingM),
        // Tabs
        TabBar(
          controller: tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(text: 'Mali Müşavirler'),
            Tab(text: 'Müşteriler'),
            Tab(text: 'Davetler'),
          ],
        ),
        const SizedBox(height: ThemeSize.spacingM),
        // Expanded body for scrollable content
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              ListView(
                padding: const ThemePadding.marginBottom16(),
                children: [
                  const SizedBox(height: ThemeSize.spacingM),
                  _CnnContactsSection(
                    statusLabel: statusLabel,
                    isContactsLoading: isContactsLoading,
                    contacts: contacts,
                    contactsError: contactsError,
                    onRetry: loadSupervisors,
                    onRemoveAccess: handleRemoveSupervisorAccess,
                  ),
                  const SizedBox(height: ThemeSize.spacingL),
                  _CnnFeaturedStats(contacts: contacts),
                ],
              ),
              ListView(
                padding: const ThemePadding.marginBottom16(),
                children: [
                  _CnnCustomersSection(
                    isCustomersLoading: isCustomersLoading,
                    customers: customers,
                    customersError: customersError,
                    onRetry: loadCustomers,
                  ),
                ],
              ),
              ListView(
                padding: const ThemePadding.marginBottom24(),
                children: [
                  if (isPendingInvitesLoading || pendingInvites.isNotEmpty)
                    _CnnPendingInvitesSection(
                      pendingInvites: pendingInvites,
                      isPendingLoading: isPendingInvitesLoading,
                      onAccept: handleAcceptInvite,
                    ),
                  if (isPendingInvitesLoading || pendingInvites.isNotEmpty)
                    const SizedBox(height: ThemeSize.spacingL),
                  _CnnInviteSection(
                    handleInvite: handleInvite,
                    isInviteLoading: isInviteLoading,
                    isEmailFieldFocused: isEmailFieldFocused,
                    inviteCanViewReceipts: inviteCanViewReceipts,
                    inviteCanDownloadFiles: inviteCanDownloadFiles,
                    emailController: mailController,
                    emailFocusNode: mailFocusNode,
                  ),
                  const SizedBox(height: ThemeSize.spacingM),
                  _CnnInviteTableSection(
                    statusText: statusText,
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
