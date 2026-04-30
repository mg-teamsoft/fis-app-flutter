import 'dart:math' as math;

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/home_service.dart';
import 'package:fis_app_flutter/app/widget/twice_button.dart';
import 'package:fis_app_flutter/feature/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part '../controller/home_controller.dart';
part '../view/home_view.dart';
part '../widget/home/hm_action.dart';
part '../widget/home/hm_error.dart';
part '../widget/home/hm_header.dart';
part '../widget/home/hm_invoice_item.dart';
part '../widget/home/hm_loading.dart';
part '../widget/home/hm_recent_receipt.dart';
part '../widget/home/hm_target_progress_ring.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with _ConnectionHome {
  @override
  Widget build(BuildContext context) {
    return _LoadingHome(
      summary: _futureSummary,
      reload: _reload,
      size: _size,
      dateString: _dateString,
    );
  }
}
