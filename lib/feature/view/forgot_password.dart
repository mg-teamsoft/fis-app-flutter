part of '../page/forget_password.dart';

final class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView({
    required this.scrollController,
    required this.formKey,
    required this.auth,
    required this.loading,
    required this.mailController,
    required this.submit,
    this.statusMessage,
    this.errorMessage,
  });

  final TextEditingController mailController;
  final ScrollController scrollController;
  final GlobalKey<FormState> formKey;
  final AuthService auth;
  final bool loading;
  final Future<void> Function() submit;
  final String? statusMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: ThemeSize.spacingXXXl,
            ),
            const _ForgotPasswordHeader(),
            const SizedBox(height: ThemeSize.spacingL),
            _ForgotPasswordTextField(
              controller: mailController,
              submit: submit,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            _ForgotPasswordMessage(
              errorMessage: errorMessage,
              statusMessage: statusMessage,
            ),
            const SizedBox(
              height: ThemeSize.spacingL,
            ),
            _ForgotPasswordFiiledButton(loading: loading, submit: submit),
            const SizedBox(height: ThemeSize.spacingXXXl),
            _ForgotPasswordBackButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
            ),
            const SizedBox(height: ThemeSize.spacingXXXl),
          ],
        ),
      ),
    );
  }
}
