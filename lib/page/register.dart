
import 'package:fis_app_flutter/feature/view/register.dart';
import 'package:fis_app_flutter/models/plan_option.dart';
import 'package:fis_app_flutter/services/auth_service.dart';
import 'package:fis_app_flutter/services/plan_service.dart';
import 'package:fis_app_flutter/theme/theme.dart';
import 'package:flutter/material.dart';

part '../feature/view/register_mixin.dart';
part '../feature/components/register_body.dart';

final class PageRegister extends StatefulWidget {
  const PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

final class _PageRegisterState extends State<PageRegister> with MixinRegister {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.brandPrimary,
      body: BodyRegister(
        formKey: _formKey,
        req: _req,
        reqpass: _validatePassword,
        usernameController: _userCtrl,
        mailController: _emailCtrl,
        passwordController: _passCtrl,
        scrollController: _scrollCtrl,
        state: _state,
        onRegister: _onRegister,
        planFuture: _plansFuture,
        retryFunction: _retryPlans,
      ),
    );
  }
}
