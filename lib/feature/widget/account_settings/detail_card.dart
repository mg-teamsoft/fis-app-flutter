part of '../../page/account_settings.dart';

class _AccountSettingsDetailsCard extends StatelessWidget {
  const _AccountSettingsDetailsCard({
    required this.user,
    required this.resendingVerification,
    required this.onResendVerification,
  });

  final UserProfile user;
  final bool resendingVerification;
  final VoidCallback onResendVerification;

  @override
  Widget build(BuildContext context) {
    final createdAt = user.createdAt;
    final createdAtLabel = createdAt != null
        ? DateFormat('d MMMM yyyy', 'tr_TR').format(createdAt)
        : '-';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kullanıcı Adı',
            style: TextStyle(color: Color(0xFF667085)),
          ),
          const SizedBox(height: 6),
          Text(
            user.userName,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.w600,
              fontSize: 32 / 2,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          const SizedBox(height: 14),
          const Text('E-posta', style: TextStyle(color: Color(0xFF667085))),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.w500,
              fontSize: 32 / 2,
            ),
          ),
          if (!user.emailVerified) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2D7A7)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFB54708),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'E-posta doğrulanmadı',
                      style: TextStyle(
                        color: Color(0xFFB54708),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        resendingVerification ? null : onResendVerification,
                    child: resendingVerification
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Tekrar Gönder'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          const SizedBox(height: 14),
          const Text(
            'Hesap Oluşturma',
            style: TextStyle(
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            createdAtLabel,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.w500,
              fontSize: 32 / 2,
            ),
          ),
        ],
      ),
    );
  }
}
