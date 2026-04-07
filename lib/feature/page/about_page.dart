import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

part '../controller/about_controller.dart';
part '../view/about_view.dart';
part '../widget/about/ab_feature_tile.dart';

final class PageAbout extends StatefulWidget {
  const PageAbout({super.key});

  @override
  State<PageAbout> createState() => _PageAboutState();
}

final class _PageAboutState extends State<PageAbout> with _ConnectionAbout {
  @override
  Widget build(BuildContext context) {
    return const _AboutView();
  }
}
