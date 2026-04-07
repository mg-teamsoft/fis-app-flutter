import 'dart:async';

import 'package:fis_app_flutter/app/config/contact_permission.dart';
import 'package:fis_app_flutter/app/services/connections_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part '../controller/contact_controller.dart';
part '../view/contact_view.dart';
part '../widget/contact/cnt_class.dart';

class PageContact extends StatefulWidget {
  const PageContact({super.key});

  @override
  State<PageContact> createState() => _PageContactState();
}

class _PageContactState extends State<PageContact>
    with SingleTickerProviderStateMixin, _ContactController {
  @override
  Widget build(BuildContext context) {
    return _ContactView(
      isInviteLoading: _isInviteLoading,
      isContactsLoading: _isContactsLoading,
      isInvitesLoading: _isInvitesLoading,
      isEmailFieldFocused: _isEmailFieldFocused,
      inviteCanViewReceipts: _inviteCanViewReceipts,
      inviteCanDownloadFiles: _inviteCanDownloadFiles,
      tabController: _tabController,
      mailController: _emailController,
      mailFocusNode: _emailFocusNode,
      connectionsService: _connectionsService,
      resendingInviteIds: _resendingInviteIds,
      contacts: _contacts,
      invites: _invites,
      contactsError: _contactsError,
      invitesError: _invitesError,
      loadSupervisors: _loadSupervisors,
      loadInvites: _loadInvites,
      handleInvite: _handleInvite,
      handleResendInvite: _handleResendInvite,
    );
  }
}
