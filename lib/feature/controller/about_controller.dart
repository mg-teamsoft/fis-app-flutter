part of '../page/about_page.dart';

mixin _ConnectionAbout on State<PageAbout> {
  late Size size;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.sizeOf(context);
  }
}
