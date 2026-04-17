import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';

part '../controller/reset_password_controller.dart';
part '../view/reset_password_view.dart';
part '../widget/reset_password/respas_back_button.dart';
part '../widget/reset_password/respas_error.dart';
part '../widget/reset_password/respas_filled_button.dart';
part '../widget/reset_password/respas_header.dart';
part '../widget/reset_password/respas_logo.dart';
part '../widget/reset_password/respas_password_confirm_textfield.dart';
part '../widget/reset_password/respas_password_textfield.dart';

class PageResetPassword extends StatefulWidget {
  const PageResetPassword({super.key, this.initialToken, this.init});
  final String? initialToken;
  final bool? init;

  @override
  State<PageResetPassword> createState() => _PageResetPasswordState();
}

class _PageResetPasswordState extends State<PageResetPassword>
    with _ConnectionResetPassword {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ResetPasswordView(
        auth: _auth,
        enter: _enterStatus,
        scrollController: _scrollController,
        formKey: _formKey,
        passwordCtrl: _passwordCtrl,
        confirmCtrl: _confirmCtrl,
        status: _status,
        error: _error,
        submitting: _submitting,
        submit: _submit,
      ),
    );
  }
}
