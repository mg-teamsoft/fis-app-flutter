import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part '../connection/login.dart';
part '../view/login.dart';
part '../widget/login/error.dart';
part '../widget/login/forget_password_button.dart';
part '../widget/login/login_button.dart';
part '../widget/login/logo.dart';
part '../widget/login/password_textfield.dart';
part '../widget/login/register_button.dart';
part '../widget/login/username_textfield.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> with _ConnectionLogin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _LoginView(
      isLoading: _loading,
      usernameController: _userCtrl,
      passwordController: _passCtrl,
      scrollController: _scrollController,
      onLogin: _handleLogin,
      size: _size,
      error: _error,
    ));
  }
}
