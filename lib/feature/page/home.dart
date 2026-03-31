import 'dart:math' as math;

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/home_service.dart';
import 'package:fis_app_flutter/app/widget/twice_button.dart';
import 'package:fis_app_flutter/feature/model/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

part '../controller/home.dart';
part '../view/home.dart';
part '../widget/home/action.dart';
part '../widget/home/error.dart';
part '../widget/home/header.dart';
part '../widget/home/loading.dart';
part '../widget/home/recent_receipt.dart';
part '../widget/home/target_progress_ring.dart';

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
    );
  }
}
