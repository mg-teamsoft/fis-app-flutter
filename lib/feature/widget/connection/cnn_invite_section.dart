part of '../../page/connection_page.dart';

class _CnnInviteSection extends StatefulWidget {
  const _CnnInviteSection({
    required this.handleInvite,
    required this.emailController,
    required this.emailFocusNode,
    required this.isEmailFieldFocused,
    required this.inviteCanViewReceipts,
    required this.inviteCanDownloadFiles,
    required this.isInviteLoading,
  });

  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final bool isEmailFieldFocused;
  final bool inviteCanViewReceipts;
  final bool inviteCanDownloadFiles;
  final bool isInviteLoading;
  final Future<void> Function() handleInvite;

  @override
  State<_CnnInviteSection> createState() => __CnnInviteSectionState();
}

class __CnnInviteSectionState extends State<_CnnInviteSection> {
  bool inviteCanViewReceipts = true;
  bool inviteCanDownloadFiles = true;

  @override
  void initState() {
    super.initState();
    inviteCanViewReceipts = widget.inviteCanViewReceipts;
    inviteCanDownloadFiles = widget.inviteCanDownloadFiles;
  }

  @override
  Widget build(BuildContext context) {
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
            'Finansal Danışman Davet Et',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ekip üyelerine finansal kayıtlarınızı görüntüleme veya yönetme erişimi verin.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.emailController,
            focusNode: widget.emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            cursorColor: const Color(0xFF2563EB),
            decoration: InputDecoration(
              hintText:
                  widget.isEmailFieldFocused ? null : 'E-posta adresi girin',
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
                child: _CnnInvitePermissionSwitch(
                  label: 'Fişleri Görüntüle',
                  value: widget.inviteCanViewReceipts,
                  onChanged: (value) {
                    setState(() {
                      inviteCanViewReceipts = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CnnInvitePermissionSwitch(
                  label: 'Dosyaları İndir',
                  value: widget.inviteCanDownloadFiles,
                  onChanged: (value) {
                    setState(() {
                      inviteCanDownloadFiles = value;
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
              onPressed: widget.isInviteLoading ? null : widget.handleInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isInviteLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Davet Et'),
            ),
          ),
        ],
      ),
    );
  }
}
