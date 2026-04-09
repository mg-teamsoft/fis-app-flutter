part of '../../page/connection_page.dart';

class _Contact {
  _Contact({
    required this.canViewReceipts,
    required this.canDownloadFiles,
    required this.id,
    required this.initials,
    required this.name,
    required this.email,
    required this.status,
    required this.baseColor,
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
