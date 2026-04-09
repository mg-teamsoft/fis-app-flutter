part of '../../page/connection_page.dart';

class _CnnContactsSection extends StatelessWidget {
  const _CnnContactsSection({
    required this.statusLabel,
    required this.isContactsLoading,
    required this.contacts,
    required this.contactsError,
    required this.onRetry,
  });

  final bool isContactsLoading;
  final List<_Contact> contacts;
  final String? contactsError;
  final VoidCallback onRetry;
  final String Function(String) statusLabel;

  @override
  Widget build(BuildContext context) {
    if (isContactsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (contactsError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contactsError!,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (contacts.isEmpty) {
      return Container(
        width: double.infinity,
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
      );
    }

    return Column(
      children: contacts
          .map(
            (contact) =>
                _ConnectionCard(contact: contact, statusLabel: statusLabel),
          )
          .toList(),
    );
  }
}
