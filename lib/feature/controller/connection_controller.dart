part of '../page/connection_page.dart';

mixin _ConnectionController on State<PageConnections>, TickerProvider {
  // Variables
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final ConnectionsService _connectionsService = ConnectionsService();
  bool _isInviteLoading = false;
  bool _isContactsLoading = true;
  bool _isInvitesLoading = true;
  bool _isEmailFieldFocused = false;
  bool _inviteCanViewReceipts = true;
  bool _inviteCanDownloadFiles = true;
  Set<String> _resendingInviteIds = <String>{};
  String? _contactsError;
  String? _invitesError;
  List<_Contact> _contacts = const [];
  List<ContactInviteDto> _invites = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _emailFocusNode.addListener(() {
      if (!mounted) return;
      setState(() {
        _isEmailFieldFocused = _emailFocusNode.hasFocus;
      });
    });
    unawaited(_loadSupervisors());
    unawaited(_loadInvites());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir e-posta adresi girin')),
      );
      return;
    }

    final permissions = <ContactPermission>[
      if (_inviteCanViewReceipts) ContactPermission.viewReceipts,
      if (_inviteCanDownloadFiles) ContactPermission.downloadFiles,
    ];

    if (permissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir yetki seçin')),
      );
      return;
    }

    setState(() {
      _isInviteLoading = true;
    });

    try {
      await _connectionsService.inviteSupervisor(
        email: email,
        permissions: permissions,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Davet başarıyla gönderildi!')),
        );
        setState(() {
          _emailController.clear();
          _inviteCanViewReceipts = true;
          _inviteCanDownloadFiles = true;
        });
        await _loadSupervisors();
        await _loadInvites();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInviteLoading = false;
        });
      }
    }
  }

  Future<void> _loadSupervisors() async {
    setState(() {
      _isContactsLoading = true;
      _contactsError = null;
    });

    try {
      final supervisors = await _connectionsService.fetchSupervisors();
      if (!mounted) return;

      setState(() {
        _contacts = supervisors.map(_mapContact).toList();
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _contactsError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isContactsLoading = false;
        });
      }
    }
  }

  Future<void> _loadInvites() async {
    setState(() {
      _isInvitesLoading = true;
      _invitesError = null;
    });

    try {
      final invites = await _connectionsService.fetchInvites();
      if (!mounted) return;

      setState(() {
        _invites = invites;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _invitesError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInvitesLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendInvite(ContactInviteDto invite) async {
    if (invite.id.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir davet bulunamadı')),
      );
      return;
    }

    setState(() {
      _resendingInviteIds = {..._resendingInviteIds, invite.id};
    });

    try {
      await _connectionsService.resendInvite(invite.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Davet yeniden gönderildi')),
      );
      await _loadInvites();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _resendingInviteIds = {..._resendingInviteIds}..remove(invite.id);
        });
      }
    }
  }

  _Contact _mapContact(SupervisorContactDto supervisor) {
    return _Contact(
      id: supervisor.id,
      initials: _buildInitials(supervisor.name, supervisor.email),
      name: supervisor.name.isEmpty ? supervisor.email : supervisor.name,
      email: supervisor.email,
      status: supervisor.status,
      baseColor: _statusColor(supervisor.status),
      canViewReceipts:
          supervisor.permissions.contains(ContactPermission.viewReceipts),
      canDownloadFiles:
          supervisor.permissions.contains(ContactPermission.downloadFiles),
    );
  }

  String _buildInitials(String name, String email) {
    final source = name.trim().isNotEmpty ? name.trim() : email.trim();
    final parts =
        source.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      final single = parts.first.replaceAll('@', '');
      return single.substring(0, single.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return context.theme.brandPrimary;
      case 'PENDING':
        return context.theme.warning;
      case 'ACCEPTED':
        return const Color(0xFF12B76A);
      case 'EXPIRED':
        return const Color(0xFFF97066);
      default:
        return Colors.indigo;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Aktif';
      case 'PENDING':
        return 'Beklemede';
      case 'ACCEPTED':
        return 'Kabul Edildi';
      case 'EXPIRED':
        return 'Süresi Doldu';
      default:
        return status;
    }
  }

  String _formatShortDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return DateFormat('MMM d, yyyy', 'en_US').format(value.toLocal());
  }
}
