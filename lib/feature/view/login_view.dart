part of '../page/login_page.dart';

final class _LoginView extends StatelessWidget {
  const _LoginView({
    required this.translations,
    required this.isLoading,
    required this.usernameController,
    required this.passwordController,
    required this.scrollController,
    required this.onLogin,
    required this.size,
    required this.error,
  });

final Translations translations;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final ScrollController scrollController;
  final VoidCallback onLogin;
  final Size size;
  final String? error;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const ThemePadding.all24(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ThemeSize.spacingL,
        children: [
          SizedBox(height: size.height * 0.075),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppThemeButton(),
              LocalizationButton(),
            ],
          ),
          const SizedBox(height: ThemeSize.spacingXXl),
          const _LoginLogo(),
          _UsernameTextField(usernameController, translations),
          _PasswordTextField(
            controller: passwordController,
            onPressed: onLogin,
            translations: translations,
          ),
          const SizedBox(height: ThemeSize.spacingL),
          if (error != null) ...[
            _LoginErrorText(message: error!),
            const SizedBox(height: ThemeSize.spacingL),
          ],
          _LoginButton(
            isLoading: isLoading,
            onPressed: onLogin,
            translations: translations,
          ),
          _RegisterButton(translations: translations),
          _ForgetPasswordButton(translations: translations),
        ],
      ),
    );
  }
}
