import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/core/enter_app.dart';
import 'package:fis_app_flutter/model/plan_option.dart';
import 'package:fis_app_flutter/services/auth_service.dart';
import 'package:fis_app_flutter/services/plan_service.dart';
import 'package:flutter/material.dart';

part '../connection/register.dart';
part '../view/register.dart';
part '../widget/register/error_text.dart';
part '../widget/register/logo.dart';
part '../widget/register/mail_textfield.dart';
part '../widget/register/password_textfield.dart';
part '../widget/register/plan_area.dart';
part '../widget/register/plan_error.dart';
part '../widget/register/plan_loading.dart';
part '../widget/register/plan_tile.dart';
part '../widget/register/register_back_button.dart';
part '../widget/register/register_button.dart';
part '../widget/register/username_textfield.dart';

class PageRegister extends StatefulWidget {
  const PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> with _ConnectionRegister {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _RegisterView(
        formKey: _formKey,
        scrollController: _scrollController,
        validator: _coreEnterApp,
        userCtrl: _userCtrl,
        emailCtrl: _emailCtrl,
        passCtrl: _passCtrl,
        obscure: _obscure,
        plansFuture: _plansFuture,
        selectedPlanKey: _selectedPlanKey,
        error: _error,
        loading: _loading,
        onRegister: _onRegister,
        retryPlans: _retryPlans,
      ),
    );
  }
}
