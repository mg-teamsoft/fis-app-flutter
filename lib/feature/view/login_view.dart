part of '../page/login_page.dart';

final class _LoginView extends StatelessWidget {
  const _LoginView({
    required this.isLoading,
    required this.usernameController,
    required this.passwordController,
    required this.scrollController,
    required this.onLogin,
    required this.size,
    required this.error,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final ScrollController scrollController;
  final VoidCallback onLogin;
  final Size size;
  final String? error;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const ThemePadding.all24(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: ThemeSize.spacingL,
          children: [
            SizedBox(height: size.height * 0.075),
            const _LoginLogo(),
            _UsernameTextField(usernameController),
            _PasswordTextField(
              controller: passwordController,
              onPressed: onLogin,
            ),
            const SizedBox(height: ThemeSize.spacingL),
            if (error != null) ...[
              _LoginErrorText(message: error!),
              const SizedBox(height: ThemeSize.spacingL),
            ],
            _LoginButton(
              isLoading: isLoading,
              onPressed: onLogin,
            ),
            const _RegisterButton(),
            const _ForgetPasswordButton(),
          ],
        ),
      ),
    );
  }
}
