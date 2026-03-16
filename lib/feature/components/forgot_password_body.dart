part of '../../page/forgot_password.dart';

class BodyResetPassword extends StatelessWidget {
  const BodyResetPassword(
      {super.key,
      required this.formKey,
      required this.scrollController,
      required this.onForgotPassword,
      required this.state,
      required this.controller,
      required this.funcCtrl,
      });
  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final Future<void> Function() onForgotPassword;
  final ValueNotifier<ForgotPasswordPageState> state;
    final TextEditingController controller;
  final String? Function(String? value) funcCtrl;


  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.height;
    return SafeArea(
        child: SingleChildScrollView(
            controller: scrollController,
            padding: ThemePadding.all24(),
            child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: ThemeSize.spacingL,
                  children: [
                    
                    SizedBox(height: size * 0.075),
                    _ForgotPasswordLogo(),
                    _ForgotPasswordTitle(),
                    _ForgotPasswordWarningText(),
                    _ForgotPasswordTextForm(controller: controller, submit: onForgotPassword, funcCtrl: funcCtrl),
                    _ForgotPasswordStateSection(
                        state: state, onForgotPassword: onForgotPassword)
                  ],
                ))));
  }
}

final class _ForgotPasswordStateSection extends StatelessWidget {
  const _ForgotPasswordStateSection(
      {required this.state, required this.onForgotPassword});

  final ValueNotifier<ForgotPasswordPageState> state;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ForgotPasswordPageState>(
      valueListenable: state,
      builder: (context, currentState, _) {
        return Column(
          children: [
            if (currentState.errorMessage.isNotEmpty)
              _ForgotPasswordErrorText(message: currentState.errorMessage),
            const SizedBox(height: ThemeSize.spacingL),
            _ForgotPasswordButton(
              isLoading: currentState.isLoading,
              onPressed: onForgotPassword,
            ),
            SizedBox(height: ThemeSize.spacingXl),
            _ForgotPasswordBackButton()
          ],
        );
      },
    );
  }
}

final class _ForgotPasswordBackButton extends StatelessWidget {
  const _ForgotPasswordBackButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: ThemeTypography.titleLarge(context, 'Giriş Ekranına Dön',
            color: context.colorScheme.secondary));
  }
}

final class _ForgotPasswordErrorText extends StatelessWidget {
  const _ForgotPasswordErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ThemeTypography.bodySmall(
      context,
      message,
      color: context.colorScheme.error,
    );
  }
}

final class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton(
      {required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: ThemeRadius.circular8),
            backgroundColor: context.appTheme.brandSecondary,
            padding: ThemePadding.all10(),
            minimumSize: const Size(120, 40)),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: ThemeSize.spacingL,
                children: [
                  Icon(
                    Icons.login,
                    color: context.colorScheme.onSecondary,
                    size: ThemeSize.iconLarge,
                  ),
                  ThemeTypography.h4(context, 'Şifre Sıfırlama',
                      color: context.colorScheme.onSecondary)
                ],
              ),
      ),
    );
  }
}

final class _ForgotPasswordWarningText extends StatelessWidget {
  const _ForgotPasswordWarningText();

  @override
  Widget build(BuildContext context) {
    return ThemeTypography.bodyLarge(
      context,
      'E-posta adresinizi girin. Şifre sıfırlama adımlarını içeren bir e-posta göndereceğiz.',
      textAlign: TextAlign.center,
    );
  }
}

final class _ForgotPasswordLogo extends StatelessWidget {
  const _ForgotPasswordLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/icon/RBGAppIcon.png',
        width: ThemeSize.avatarXL, height: ThemeSize.avatarXL);
  }
}

final class _ForgotPasswordTitle extends StatelessWidget {
  const _ForgotPasswordTitle();

  @override
  Widget build(BuildContext context) {
    return ThemeTypography.h4(context, 'Şifremi Unuttum');
  }
}

final class _ForgotPasswordTextForm extends StatelessWidget {
  const _ForgotPasswordTextForm(
      {required this.controller, required this.submit,required this.funcCtrl});
  final TextEditingController controller;
  final String? Function(String? value) funcCtrl;
  final Future<void> Function() submit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: 'Mail Adresiniz',
          prefixIcon: Icon(Icons.mail_outline_rounded,
              color: context.colorScheme.onPrimary)),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: (value) => funcCtrl(value),
      onFieldSubmitted: (_) => submit(),
    );
  }
}
