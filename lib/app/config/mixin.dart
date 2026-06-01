part of './general.dart';

mixin _AppConfigMixin on State<AppConfigGeneral> {
  late RouterGeneral _router;


  @override
  void initState() {
    super.initState();
    _router = RouterGeneral();
  }
}
