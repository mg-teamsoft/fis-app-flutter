part of '../../page/connection_page.dart';

class _CnnContactsSection extends StatelessWidget {
  const _CnnContactsSection({
    required this.statusLabel,
    required this.isContactsLoading,
    required this.contacts,
    required this.contactsError,
    required this.onRetry,
    required this.onRemoveAccess,
  });

  final bool isContactsLoading;
  final List<_Contact> contacts;
  final String? contactsError;
  final VoidCallback onRetry;
  final Future<void> Function(_Contact) onRemoveAccess;
  final String Function(String) statusLabel;

  @override
  Widget build(BuildContext context) {
    if (isContactsLoading) {
      return const Padding(
        padding: ThemePadding.verticalSymmetricLarge(),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (contactsError != null) {
      return Container(
        padding: const ThemePadding.all16(),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: ThemeRadius.circular12,
          border: Border.all(color: context.theme.error),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeTypography.bodyMedium(
              context,
              contactsError!,
              color: context.theme.error,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            ElevatedButton(
              onPressed: onRetry,
              child: ThemeTypography.bodyMedium(
                context,
                'Tekrar Dene',
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (contacts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const ThemePadding.all16(),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: ThemeRadius.circular12,
          border: Border.all(color: context.theme.divider),
        ),
        child: ThemeTypography.bodyMedium(
          context,
          'Henüz bir danışman bağlantısı bulunmuyor.',
          color: context.colorScheme.onSurface,
        ),
      );
    }

    return Column(
      children: contacts
          .map(
            (contact) => _ConnectionCard(
              contact: contact,
              statusLabel: statusLabel,
              onRemoveAccess: onRemoveAccess,
            ),
          )
          .toList(),
    );
  }
}
