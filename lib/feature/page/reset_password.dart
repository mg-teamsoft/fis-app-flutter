import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';

part '../connection/reset_password.dart';
part '../view/reset_password.dart';
part '../widget/reset_password/back_button.dart';
part '../widget/reset_password/error.dart';
part '../widget/reset_password/filled_button.dart';
part '../widget/reset_password/header.dart';
part '../widget/reset_password/logo.dart';
part '../widget/reset_password/password_confirm_textfield.dart';
part '../widget/reset_password/password_textfield.dart';

class PageResetPassword extends StatefulWidget {
  const PageResetPassword({super.key, this.initialToken});
  final String? initialToken;

  @override
  State<PageResetPassword> createState() => _PageResetPasswordState();
}

class _PageResetPasswordState extends State<PageResetPassword>
    with _ConnectionResetPassword {
  @override
  Widget build(BuildContext context) {
    return _ResetPasswordView(
      auth: _auth,
      scrollController: _scrollController,
      formKey: _formKey,
      passwordCtrl: _passwordCtrl,
      confirmCtrl: _confirmCtrl,
      status: _status,
      error: _error,
      submitting: _submitting,
      submit: _submit,
    );
  }
}
