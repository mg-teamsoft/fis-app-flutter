import 'package:fis_app_flutter/app/config/contact_permission.dart';
import 'package:fis_app_flutter/app/services/connections_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Contact {
  final String id;
  final String initials;
  final String name;
  final String email;
  final String status;
  final Color baseColor;
  bool canViewReceipts;
  bool canDownloadFiles;

  Contact({
    required this.id,
    required this.initials,
    required this.name,
    required this.email,
    required this.status,
    required this.baseColor,
    this.canViewReceipts = false,
    this.canDownloadFiles = false,
  });
}

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage>
    with SingleTickerProviderStateMixin {
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
  List<Contact> _contacts = const [];
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
    _loadSupervisors();
    _loadInvites();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(text: "Mali Müşavirler"),
            Tab(text: "Davetler"),
          ],
        ),
        const SizedBox(height: 16),
        // Expanded body for scrollable content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildInviteSection(context),
                  const SizedBox(height: 16),
                  ..._buildContactsSection(context),
                  const SizedBox(height: 24),
                  _buildFeaturedStats(context),
                ],
              ),
              ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildInvitesTableSection(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInviteSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Finansal Danışman Davet Et",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Ekip üyelerine finansal kayıtlarınızı görüntüleme veya yönetme erişimi verin.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            cursorColor: const Color(0xFF2563EB),
            decoration: InputDecoration(
              hintText: _isEmailFieldFocused ? null : "E-posta adresi girin",
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInvitePermissionSwitch(
                  label: "Fişleri Görüntüle",
                  value: _inviteCanViewReceipts,
                  onChanged: (value) {
                    setState(() {
                      _inviteCanViewReceipts = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInvitePermissionSwitch(
                  label: "Dosyaları İndir",
                  value: _inviteCanDownloadFiles,
                  onChanged: (value) {
                    setState(() {
                      _inviteCanDownloadFiles = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isInviteLoading ? null : _handleInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isInviteLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Davet Et"),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContactsSection(BuildContext context) {
    if (_isContactsLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_contactsError != null) {
      return [
        Container(
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
                _contactsError!,
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadSupervisors,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ];
    }

    if (_contacts.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            'Henüz bir danışman bağlantısı bulunmuyor.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ];
    }

    return _contacts
        .map((contact) => _buildContactCard(contact, context))
        .toList();
  }

  Widget _buildInvitePermissionSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 4),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              return Colors.white;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF2563EB);
              }
              return const Color(0xFFE2E8F0);
            }),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              return Colors.transparent;
            }),
          ),
        ],
      ),
    );
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
        _loadSupervisors();
        _loadInvites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Hata: ${e.toString().replaceAll('Exception: ', '')}')),
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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

  Contact _mapContact(SupervisorContactDto supervisor) {
    return Contact(
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
        return Colors.blue;
      case 'PENDING':
        return const Color(0xFFEFB53E);
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

  Widget _buildInvitesTableSection(BuildContext context) {
    if (_isInvitesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_invitesError != null) {
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
              _invitesError!,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadInvites,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_invites.isEmpty) {
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

    final pendingCount = _invites
        .where((invite) => invite.status.toUpperCase() == 'PENDING')
        .length;

    return Column(
      children: [
        _buildInviteSummaryCard(context, pendingCount),
        const SizedBox(height: 16),
        ..._invites.map((invite) => _buildInviteCard(context, invite)),
      ],
    );
  }

  String _formatShortDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return DateFormat('MMM d, yyyy', 'en_US').format(value.toLocal());
  }

  Widget _buildInviteSummaryCard(BuildContext context, int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÖZET',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF7B8193),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D4ED8),
                  ),
              children: [
                TextSpan(text: '$pendingCount'),
                const TextSpan(
                  text: ' Beklemede',
                  style: TextStyle(color: Color(0xFF1D4ED8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finansal danışmanlarınıza gönderilen davetiyeleri yönetin. İzinleri inceleyin ve durumu gerçek zamanlı olarak takip edin.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF667085),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, ContactInviteDto invite) {
    final statusColor = _statusColor(invite.status);
    final isPending = invite.status.toUpperCase() == 'PENDING';
    final isExpired = invite.status.toUpperCase() == 'EXPIRED';
    final hasResponded = invite.respondedAt != null;
    final isResending = _resendingInviteIds.contains(invite.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAVET EDİLEN E-POSTA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF98A2B3),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            invite.inviteeEmail.isEmpty ? '-' : invite.inviteeEmail,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101828),
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              invite.status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInviteMetaItem(
                  label: 'OLUŞTURULMA',
                  value: _formatShortDate(invite.createdAt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInviteMetaItem(
                  label: hasResponded ? 'YANIT TARİHİ' : 'BİTİŞ TARİHİ',
                  value: _formatShortDate(
                    hasResponded ? invite.respondedAt : invite.expiresAt,
                  ),
                  valueColor: !hasResponded && isExpired
                      ? const Color(0xFFF97066)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isPending ? 'VERİLEN YETKİLER' : 'TALEP EDİLEN YETKİLER',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF98A2B3),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: invite.permissions.isEmpty
                ? [
                    _buildPermissionChip('-'),
                  ]
                : invite.permissions
                    .map((permission) => _buildPermissionChip(
                          _permissionLabel(permission),
                          icon: _permissionIcon(permission),
                        ))
                    .toList(),
          ),
          if (isExpired || isPending) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: isExpired && !isResending
                    ? () => _handleResendInvite(invite)
                    : null,
                icon: Icon(
                  isResending
                      ? Icons.hourglass_top
                      : isExpired
                          ? Icons.refresh
                          : Icons.schedule,
                  size: 16,
                  color: const Color(0xFF2E90FA),
                ),
                label: Text(
                  isExpired
                      ? (isResending
                          ? 'Yeniden Gönderiliyor...'
                          : 'Daveti Yeniden Gönder')
                      : 'Yanıt Bekleniyor',
                  style: const TextStyle(
                    color: Color(0xFF2E90FA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInviteMetaItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF475467),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: const Color(0xFF667085)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _permissionLabel(String permission) {
    switch (permission) {
      case 'VIEW_RECEIPTS':
        return 'Fişleri Görüntüle';
      case 'DOWNLOAD_FILES':
        return 'Dosyaları İndir';
      default:
        return permission.replaceAll('_', ' ');
    }
  }

  IconData _permissionIcon(String permission) {
    switch (permission) {
      case 'VIEW_RECEIPTS':
        return Icons.receipt_long_outlined;
      case 'DOWNLOAD_FILES':
        return Icons.download_outlined;
      default:
        return Icons.shield_outlined;
    }
  }

  Widget _buildContactCard(Contact contact, BuildContext context) {
    final bool isActive = contact.status == "ACTIVE";
    final Color statusColor = isActive ? Colors.green : Colors.orange;
    final Color cardBorderColor =
        isActive ? Colors.grey.shade300 : Colors.orange.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: contact.baseColor.withValues(alpha: 0.1),
                child: Text(
                  contact.initials,
                  style: TextStyle(
                    color: contact.baseColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _statusLabel(contact.status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      contact.email,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("Fişleri Görüntüle",
                          style: TextStyle(fontSize: 12)),
                      Switch(
                        value: contact.canViewReceipts,
                        onChanged: (v) {
                          setState(() {
                            contact.canViewReceipts = v;
                          });
                        },
                        thumbColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          return Colors.white;
                        }),
                        trackColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF2563EB);
                          }
                          return const Color(0xFFE2E8F0);
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                          return Colors.transparent;
                        }),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text("Dosyaları İndir",
                          style: TextStyle(fontSize: 12)),
                      Switch(
                        value: contact.canDownloadFiles,
                        onChanged: (v) {
                          setState(() {
                            contact.canDownloadFiles = v;
                          });
                        },
                        thumbColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          return Colors.white;
                        }),
                        trackColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF2563EB);
                          }
                          return const Color(0xFFE2E8F0);
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                          return Colors.transparent;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Erişimi Kaldır",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade800,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text("İptal Et",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white),
                  child: const Text("Yeniden Gönder"),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildFeaturedStats(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 10,
                bottom: -20,
                child: Icon(
                  Icons.groups,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.all(24.0), // İstediğin iç boşluk buraya
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EKİP VERİMLİLİĞİ",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Finansal danışmanlarınızla\nsorunsuz şekilde iş birliği yapın.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text("Daha Fazla Bilgi",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_user,
                    color: Colors.green.shade600, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                '${_contacts.length}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Aktif Danışmanlar",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
