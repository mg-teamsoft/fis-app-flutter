import 'dart:async';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/providers/purchase_provider.dart';
import 'package:fis_app_flutter/app/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/app/services/plan_service.dart';
import 'package:fis_app_flutter/app/services/purchase_transaction_service.dart';
import 'package:fis_app_flutter/app/services/user_service.dart';
import 'package:fis_app_flutter/model/plan_option.dart';
import 'package:fis_app_flutter/model/product_type_enum.dart';
import 'package:fis_app_flutter/model/purchase_transaction.dart';
import 'package:fis_app_flutter/model/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

part '../controller/account_settings_controller.dart';
part '../view/account_settings_view.dart';
part '../widget/account_settings/acset_active_plan.dart';
part '../widget/account_settings/acset_available_plan_tile.dart';
part '../widget/account_settings/acset_detail_card.dart';
part '../widget/account_settings/acset_empty_plan_card.dart';
part '../widget/account_settings/acset_payment_detail.dart';
part '../widget/account_settings/acset_plan_card.dart';
part '../widget/account_settings/acset_reset_password_button.dart';
part '../widget/account_settings/acset_section_title.dart';
part '../widget/account_settings/acset_update_button.dart';

class PageAccountSettings extends StatefulWidget {
  const PageAccountSettings({super.key});

  @override
  State<PageAccountSettings> createState() => _PageAccountSettingsState();
}

class _PageAccountSettingsState extends State<PageAccountSettings>
    with _ConnectionAccountSettings {
  @override
  void _onPlanSelected(String planKey) {
    setState(() => _selectedPlanKey = planKey);
  }

  @override
  Widget build(BuildContext context) {
    return _AccountSettingsView(
      scrollController: _scrollController,
      loading: _loading,
      updatingPlan: _updatingPlan,
      resendingVerification: _resendingVerification,
      error: _error,
      transactionError: _transactionError,
      currentPlanKey: _currentPlanKey,
      selectedPlanKey: _selectedPlanKey,
      plans: _plans,
      user: _user,
      transactions: _transactions.take(_visibleTransactions).toList(),
      activePlan: _activePlan,
      navSpacer: _navSpacer,
      loadAll: _loadAll,
      onRefresh: _onRefresh,
      onResendVerification: _onResendVerification,
      onBuyAdditional: _onBuyAdditional,
      onPlanSelected: _onPlanSelected,
      onUpdatePlan: _onUpdatePlan,
      availablePlanBackground: _availablePlanBackground,
      availablePlanBorder: _availablePlanBorder,
      onResetPassword: _onResetPassword,
    );
  }
}
