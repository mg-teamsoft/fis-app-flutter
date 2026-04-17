import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part '../controller/login_controller.dart';
part '../view/login_view.dart';
part '../widget/login/lg_button.dart';
part '../widget/login/lg_error.dart';
part '../widget/login/lg_forget_password_button.dart';
part '../widget/login/lg_logo.dart';
part '../widget/login/lg_password_textfield.dart';
part '../widget/login/lg_register_button.dart';
part '../widget/login/lg_username_textfield.dart';

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
      ),
    );
  }
}
