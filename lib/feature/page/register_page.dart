import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/auth_service.dart';
import 'package:fis_app_flutter/app/services/plan_service.dart';
import 'package:fis_app_flutter/core/enter_app.dart';
import 'package:fis_app_flutter/model/plan_option.dart';
import 'package:flutter/material.dart';

part '../controller/register_controller.dart';
part '../view/register_view.dart';
part '../widget/register/rg_back_button.dart';
part '../widget/register/rg_button.dart';
part '../widget/register/rg_error_text.dart';
part '../widget/register/rg_logo.dart';
part '../widget/register/rg_mail_textfield.dart';
part '../widget/register/rg_password_textfield.dart';
part '../widget/register/rg_plan_area.dart';
part '../widget/register/rg_plan_error.dart';
part '../widget/register/rg_plan_loading.dart';
part '../widget/register/rg_plan_tile.dart';
part '../widget/register/rg_username_textfield.dart';

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
        onPlanSelected: _onPlanSelected,
      ),
    );
  }
}
