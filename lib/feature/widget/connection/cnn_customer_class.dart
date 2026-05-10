part of '../../page/connection_page.dart';

class _Customer {
  _Customer({
    required this.id,
    required this.initials,
    required this.name,
    required this.email,
    required this.baseColor,
    required this.canViewReceipts,
    required this.canDownloadFiles,
  });
  final String id;
  final String initials;
  final String name;
  final String email;
  final Color baseColor;
  final bool canViewReceipts;
  final bool canDownloadFiles;
}
