part of '../../page/login.dart';

class BodyLogin extends StatelessWidget {
  const BodyLogin({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.scrollController,
    required this.state,
    required this.onLogin,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final ScrollController scrollController;
  final ValueNotifier<LoginPageState> state;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.height;
    return SafeArea(
        child: SingleChildScrollView(
            controller: scrollController,
            padding: ThemePadding.all24(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: ThemeSize.spacingL,
              children: [
                SizedBox(height: size * 0.075),
                _LoginLogo(),
                _UsernameTextField(usernameController),
                _PasswordTextField(controller: passwordController),
                SizedBox(height: ThemeSize.spacingL),
                _LoginStateSection(state: state, onLogin: onLogin),
                _RegisterButton(),
                _ForgetPasswordButton(),
              ],
            )));
  }
}

final class _LoginStateSection extends StatelessWidget {
  const _LoginStateSection({required this.state, required this.onLogin});

  final ValueNotifier<LoginPageState> state;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoginPageState>(
      valueListenable: state,
      builder: (context, currentState, _) {
        return Column(
          children: [
            if (currentState.errorMessage.isNotEmpty)
              _LoginErrorText(message: currentState.errorMessage),
            const SizedBox(height: ThemeSize.spacingL),
            _LoginButton(
              isLoading: currentState.isLoading,
              onPressed: onLogin,
            ),
          ],
        );
      },
    );
  }
}

final class _UsernameTextField extends StatelessWidget {
  const _UsernameTextField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
        cursorColor: context.colorScheme.outline,
        controller: controller,
        style: ThemeTypography.h4(context, '').style,
        decoration: InputDecoration(
          labelText: 'Kullanıcı Adınız',
          prefixIcon: Icon(Icons.person, size: ThemeSize.iconLarge),
        ));
  }
}

final class _PasswordTextField extends StatelessWidget {
  _PasswordTextField({required this.controller});

  final TextEditingController controller;
  final ValueNotifier<bool> _obscureNotifier = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscureNotifier,
      builder: (context, isObscure, child) {
        return TextField(
          cursorColor: context.colorScheme.outline,
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            labelText: 'Şifreniz',
            prefixIcon: Icon(Icons.lock, size: ThemeSize.iconLarge),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => _obscureNotifier.value = !_obscureNotifier.value,
            ),
          ),
        );
      },
    );
  }
}

final class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/icon/RBGAppIcon.png',
        width: ThemeSize.avatarXL, height: ThemeSize.avatarXL);
  }
}

final class _LoginErrorText extends StatelessWidget {
  const _LoginErrorText({required this.message});

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

final class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});

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
                  ThemeTypography.h4(context, 'Giriş Yap',
                      color: context.colorScheme.onSecondary)
                ],
              ),
      ),
    );
  }
}

final class _RegisterButton extends StatelessWidget {
  const _RegisterButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.of(context).pushNamed('/register'),
        child: ThemeTypography.titleLarge(context, 'Hesap Oluştur',
            color: context.colorScheme.secondary));
  }
}

final class _ForgetPasswordButton extends StatelessWidget {
  const _ForgetPasswordButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.of(context).pushNamed('/forgotPassword'),
        child: ThemeTypography.titleLarge(context, 'Şifremi Unuttum',
            color: context.colorScheme.secondary));
  }
}
