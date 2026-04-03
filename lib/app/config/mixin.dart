part of './general.dart';

mixin _AppConfigMixin on State<AppConfigGeneral> {
  late RouterGeneral _router;
  late AppLocalization _localization;

  @override
  void initState() {
    super.initState();
    _router = RouterGeneral();
    _localization = AppLocalization();
  }
}
