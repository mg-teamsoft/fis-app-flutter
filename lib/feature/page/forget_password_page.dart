import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';

part '../controller/forgot_password_controller.dart';
part '../view/forgot_password_view.dart';
part '../widget/forgot_password/fp_back_button.dart';
part '../widget/forgot_password/fp_fiiled_button.dart';
part '../widget/forgot_password/fp_header.dart';
part '../widget/forgot_password/fp_logo.dart';
part '../widget/forgot_password/fp_mail_textfield.dart';
part '../widget/forgot_password/fp_message.dart';

class PageForgotPassword extends StatefulWidget {
  const PageForgotPassword({super.key});

  @override
  State<PageForgotPassword> createState() => _PageForgotPasswordState();
}

class _PageForgotPasswordState extends State<PageForgotPassword>
    with _ConnectionForgotPassword {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ForgotPasswordView(
        scrollController: _scrollController,
        formKey: _formKey,
        auth: _auth,
        loading: _loading,
        mailController: _emailController,
        submit: _submit,
        errorMessage: _errorMessage,
        statusMessage: _statusMessage,
      ),
    );
  }
}
