import 'package:fis_app_flutter/theme/theme.dart';

import 'package:fis_app_flutter/providers/user_plan_provider.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

import 'package:flutter/material.dart';
import '../feature/view/login.dart';

part '../feature/view/login_mixin.dart';
part '../feature/components/login_body.dart';

final class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

final class _PageLoginState extends State<PageLogin> with MixinLogin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.appTheme.brandPrimary,
        body: BodyLogin(
            usernameController: _userCtrl,
            passwordController: _passCtrl,
            scrollController: _scrollCtrl,
            state: _state,
            onLogin: _handleLogin));
  }
}
