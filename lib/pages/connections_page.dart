import 'package:fis_app_flutter/app/config/contact_permission.dart';
import 'package:fis_app_flutter/app/services/connections_service.dart';
import 'package:flutter/material.dart';

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
  final ConnectionsService _connectionsService = ConnectionsService();
  bool _isInviteLoading = false;
  bool _isContactsLoading = true;
  bool _inviteCanViewReceipts = true;
  bool _inviteCanDownloadFiles = true;
  String? _contactsError;
  List<Contact> _contacts = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSupervisors();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
            Tab(text: "My Supervisors"),
            Tab(text: "My Customers"),
          ],
        ),
        const SizedBox(height: 16),
        // Expanded body for scrollable content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _buildInviteSection(context),
              const SizedBox(height: 16),
              ..._buildContactsSection(context),
              const SizedBox(height: 24),
              _buildFeaturedStats(context),
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
            "Invite Supervisor",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Grant team members access to view or manage your financial records.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email address",
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInvitePermissionSwitch(
                  label: "View Receipts",
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
                  label: "Download Files",
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
                  : const Text("Invite"),
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
                child: const Text('Retry'),
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
            'Henüz bir supervisor bağlantısı bulunmuyor.',
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
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
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  Widget _buildContactCard(Contact contact, BuildContext context) {
    final bool isActive = contact.status == "ACTIVE";
    final Color statusColor = isActive ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isActive ? Colors.grey.shade200 : Colors.grey.shade300,
            style: isActive ? BorderStyle.solid : BorderStyle.none),
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
                            contact.status,
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
                      const Text("View Receipts",
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
                      const Text("Download Files",
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
                    "Revoke Access",
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
                  child: const Text("Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white),
                  child: const Text("Resend"),
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
                      "TEAM EFFICIENCY",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Collaborate seamlessly\nwith your fiscal advisors.",
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
                      child: const Text("Learn More",
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
              const Text(
                "2",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Active Supervisors",
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
