import 'dart:async' show unawaited;

import 'package:fis_app_flutter/app/config/contact_permission.dart'
    show ContactPermission;
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/connections_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

part '../controller/connection_controller.dart';
part '../view/connection_view.dart';
part '../widget/connection/cnn_class.dart';
part '../widget/connection/cnn_contact_card.dart';
part '../widget/connection/cnn_contacts_section.dart';
part '../widget/connection/cnn_featured_stats.dart';
part '../widget/connection/cnn_invite_card.dart';
part '../widget/connection/cnn_invite_meta_item.dart';
part '../widget/connection/cnn_invite_permission_switch.dart';
part '../widget/connection/cnn_invite_section.dart';
part '../widget/connection/cnn_invite_summary_card.dart';
part '../widget/connection/cnn_invite_table_section.dart';
part '../widget/connection/cnn_pending_invites_section.dart';
part '../widget/connection/cnn_permission_chip.dart';

class PageConnections extends StatefulWidget {
  const PageConnections({super.key});

  @override
  State<PageConnections> createState() => _PageConnectionsState();
}

class _PageConnectionsState extends State<PageConnections>
    with SingleTickerProviderStateMixin, _ConnectionController {
  @override
  Widget build(BuildContext context) {
    return _ConnectionView(
      handleInvite: _handleInvite,
      loadSupervisors: _loadSupervisors,
      loadInvites: _loadInvites,
      handleResendInvite: _handleResendInvite,
      handleRemoveSupervisorAccess: _handleRemoveSupervisorAccess,
      mapContact: _mapContact,
      buildInitials: _buildInitials,
      statusColor: _statusColor,
      statusLabel: _statusLabel,
      statusText: _statusText,
      formatShortDate: _formatShortDate,
      tabController: _tabController,
      mailController: _emailController,
      mailFocusNode: _emailFocusNode,
      connectionsService: _connectionsService,
      isInviteLoading: _isInviteLoading,
      isContactsLoading: _isContactsLoading,
      isInvitesLoading: _isInvitesLoading,
      isEmailFieldFocused: _isEmailFieldFocused,
      inviteCanViewReceipts: _inviteCanViewReceipts,
      inviteCanDownloadFiles: _inviteCanDownloadFiles,
      resendingInviteIds: _resendingInviteIds,
      contactsError: _contactsError,
      invitesError: _invitesError,
      contacts: _contacts,
      invites: _invites,
      pendingInvites: _pendingInvites,
      isPendingInvitesLoading: _isPendingInvitesLoading,
      handleAcceptInvite: _handleAcceptInvite,
    );
  }
}
