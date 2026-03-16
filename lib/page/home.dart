import 'package:fis_app_flutter/feature/home_header.dart';
import 'package:fis_app_flutter/feature/view/home.dart';
import 'package:fis_app_flutter/models/home_summary.dart';
import 'package:fis_app_flutter/page/error/home_error.dart';
import 'package:fis_app_flutter/services/home_service.dart';
import 'package:fis_app_flutter/theme/theme.dart';
import 'package:fis_app_flutter/widget/button.dart';
import 'package:fis_app_flutter/widget/cardarea.dart';
import 'package:fis_app_flutter/widget/loading.dart';
import 'package:flutter/material.dart';

part '../feature/view/home_mixin.dart';
part '../feature/components/home_body.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final _homeService = HomeService();
  late Future<HomeSummary> _futureSummary;
  late ScrollController _scrollCtrl;
  late double _width;
  @override
  Widget build(BuildContext context) {
    return WidgetLoading<HomeSummary>(
        error: ({details, required onRetry}) => HomeError(onRetry: onRetry),
        future: _futureSummary,
        reload: _reload,
        body: (summary) => SingleChildScrollView(
            padding: ThemePadding.all16(),
            controller: _scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: ThemePadding.all32().bottom),
                FeatureHomeHeader(summary: summary!),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    WidgetButton(
                        size: Size(_width - 32, 40),
                        radius: ThemeRadius.circular12,
                        text: "Fiş Yükle",
                        icon: Icons.upload_rounded,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/receipt'),
                        color: context.colorScheme.secondary),
                    SizedBox(
                      height: ThemeSize.spacingM,
                    ),
                    WidgetButton(
                        size: Size(_width - 32, 40),
                        radius: ThemeRadius.circular12,
                        text: "Excel Görüntüle",
                        
                        icon: Icons.table_chart,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/excelFiles'),
                        color: context.appTheme.success),
                  ],
                ),
                SizedBox(height: ThemeSize.spacingXXXl),
                Padding(
                  padding: EdgeInsets.only(
                      left: ThemeSize.spacingS, right: ThemeSize.spacingS),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ThemeTypography.h2(context, "Son Fişler", style: TextStyle(fontWeight: FontWeight.bold) ),
                    ],
                  ),
                ),
                WidgetCardArea(summary: summary),
                SizedBox(height: ThemeSize.bottomBarHeight + ThemeSize.spacingM)
              ],
            )));
  }

  @override
  void initState() {
    super.initState();

    _scrollCtrl = ScrollController();
    _futureSummary = _homeService.fetchSummary();
  }

  @override
  void didChangeDependencies() {
    _width = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _futureSummary = _homeService.fetchSummary();
    });
    try {
      await _futureSummary;
    } catch (_) {
      // Swallow the error so the refresh animation can complete.
    }
  }
}
