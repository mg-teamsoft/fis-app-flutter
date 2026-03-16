import 'package:fis_app_flutter/feature/view/forgot_password.dart';
import 'package:fis_app_flutter/services/auth_service.dart';
import 'package:fis_app_flutter/theme/theme.dart';
import 'package:flutter/material.dart';

part '../feature/view/forgot_password_mixin.dart';
part '../feature/components/forgot_password_body.dart';

final class PageForgotPassword extends StatefulWidget {
  const PageForgotPassword({super.key});

  @override
  State<PageForgotPassword> createState() => _PageResetPasswordState();
}

class _PageResetPasswordState extends State<PageForgotPassword>
    with MixinResetPassword {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.brandPrimary,
      body: BodyResetPassword(
        formKey: _formKey,
        state: _state,
        scrollController: _scrollController,
        onForgotPassword: _submit,
        controller: _emailController,
        funcCtrl: _controlMail,
      ),
    );
  }
}
