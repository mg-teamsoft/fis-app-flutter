part of '../page/reset_password.dart';

class _ResetPasswordView extends StatelessWidget {
  const _ResetPasswordView({
    required this.auth,
    required this.scrollController,
    required this.formKey,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.status,
    required this.error,
    required this.submitting,
    required this.submit,
  });

  final AuthService auth;
  final ScrollController scrollController;
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final String? status;
  final String? error;
  final bool submitting;
  final Future<void> Function() submit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ThemeSize.spacingXXXl),
            const _ResetPasswordHeader(),
            const SizedBox(height: ThemeSize.spacingM),
            _ResetPasswordPassTextfield(
              controller: passwordCtrl,
            ),
            const SizedBox(height: ThemeSize.spacingS),
            _ResetPasswordPassConfirmTextfield(
              controller: passwordCtrl,
              confirmController: confirmCtrl,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            _ResetPasswordError(
              error: error,
              status: status,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            _ResetPasswordFilledButton(
              submitting: submitting,
              submit: submit,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            _ResetPasswordBackButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
            ),
            const SizedBox(height: ThemeSize.spacingXXXl),
          ],
        ),
      ),
    );
  }
}
