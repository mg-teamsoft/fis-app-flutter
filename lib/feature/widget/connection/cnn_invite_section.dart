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
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.theme.divider),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeTypography.titleMedium(
            context,
            'Finansal Danışman Davet Et',
            weight: FontWeight.w800,
            color: context.colorScheme.onSurface,
          ),
          const SizedBox(height: ThemeSize.spacingXs),
          ThemeTypography.bodySmall(
            context,
            'Ekip üyelerine finansal kayıtlarınızı görüntüleme veya yönetme erişimi verin.',
            color: context.colorScheme.outline,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          TextField(
            controller: widget.emailController,
            focusNode: widget.emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            cursorColor: context.colorScheme.primary,
            decoration: InputDecoration(
              hintText:
                  widget.isEmailFieldFocused ? null : 'E-posta adresi girin',
              hintStyle: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.outline,
              ),
              contentPadding: const ThemePadding.horizontalSymmetricMedium(),
              border: OutlineInputBorder(
                borderRadius: ThemeRadius.circular12,
                borderSide: BorderSide(color: context.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ThemeRadius.circular12,
                borderSide: BorderSide(color: context.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ThemeRadius.circular8,
                borderSide: BorderSide(color: context.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: ThemeSize.spacingM),
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
              const SizedBox(width: ThemeSize.spacingM),
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
          const SizedBox(height: ThemeSize.spacingXs),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isInviteLoading ? null : widget.handleInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeRadius.circular8,
                ),
              ),
              child: widget.isInviteLoading
                  ? SizedBox(
                      width: ThemeSize.iconMedium,
                      height: ThemeSize.iconMedium,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colorScheme.onSurface,
                        ),
                      ),
                    )
                  : ThemeTypography.bodyMedium(
                      context,
                      'Davet Et',
                      weight: FontWeight.w500,
                      color: context.colorScheme.surface,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
