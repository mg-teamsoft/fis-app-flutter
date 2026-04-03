import 'dart:async';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/providers/purchase_provider.dart';
import 'package:fis_app_flutter/app/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/app/services/plan_service.dart';
import 'package:fis_app_flutter/app/services/purchase_transaction_service.dart';
import 'package:fis_app_flutter/app/services/user_service.dart';
import 'package:fis_app_flutter/model/plan_option.dart';
import 'package:fis_app_flutter/model/purchase_transaction.dart';
import 'package:fis_app_flutter/model/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

part '../controller/account_settings.dart';
part '../view/account_settings.dart';
part '../widget/account_settings/active_plan.dart';
part '../widget/account_settings/available_plan_tile.dart';
part '../widget/account_settings/detail_card.dart';
part '../widget/account_settings/empty_plan_card.dart';
part '../widget/account_settings/payment_detail.dart';
part '../widget/account_settings/plan_card.dart';
part '../widget/account_settings/reset_password_button.dart';
part '../widget/account_settings/section_title.dart';
part '../widget/account_settings/update_button.dart';

class PageAccountSettings extends StatefulWidget {
  const PageAccountSettings({super.key});

  @override
  State<PageAccountSettings> createState() => _PageAccountSettingsState();
}

class _PageAccountSettingsState extends State<PageAccountSettings>
    with _ConnectionAccountSettings {
  @override
  Widget build(BuildContext context) {
    return _AccountSettingsView(
      loading: _loading,
      updatingPlan: _updatingPlan,
      resendingVerification: _resendingVerification,
      plans: _plans,
      transactions: _transactions,
      activePlan: _activePlan,
      navSpacer: _navSpacer,
      loadAll: _loadAll,
      onRefresh: _onRefresh,
      onResendVerification: _onResendVerification,
      onBuyAdditional: _onBuyAdditional,
      onUpdatePlan: _onUpdatePlan,
      availablePlanBackground: _availablePlanBackground,
      availablePlanBorder: _availablePlanBorder,
      onResetPassword: _onResetPassword,
      currentPlanKey: _currentPlanKey,
      selectedPlanKey: _selectedPlanKey,
      user: _user,
      error: _error,
      transactionError: _transactionError,
    );
  }
}
