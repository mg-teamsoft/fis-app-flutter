part of '../../page/contact_page.dart';

class _Contact {
  _Contact({
    required this.id,
    required this.initials,
    required this.name,
    required this.email,
    required this.status,
    required this.baseColor,
    this.canViewReceipts = false,
    this.canDownloadFiles = false,
  });

  final String id;
  final String initials;
  final String name;
  final String email;
  final String status;
  final Color baseColor;
  bool canViewReceipts;
  bool canDownloadFiles;
}
