import 'package:flutter/material.dart';

abstract class MyPage {
  late final AppBar appBar;
  final String route;
  final String title;
  bool _isMounted = false;
  late void Function(VoidCallback) _setState;

  MyPage(BuildContext context, {required this.route, required this.title}) {
    appBar = AppBar(
      title: appBarTitle(context) ?? Text(title),
      backgroundColor: appBarBackgroundColor() ?? Colors.white,
    );
  }

  Widget build(BuildContext context);
  Widget? appBarTitle(BuildContext context) => null;
  Color? appBarBackgroundColor() => null;
  Color? appBarForegroundColor() => null;
  Future<void> onMounted(BuildContext context);
  FloatingActionButton? floatingActionButton(BuildContext context) => null;
  void dispose() {}

  Widget body(BuildContext context) {
    if (!_isMounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async => await onMounted(context),
      );
      _isMounted = true;
    }
    return build(context);
  }

  void initState(void Function(VoidCallback) setState) {
    _setState = setState;
  }

  void setState(VoidCallback fn) {
    _setState(fn);
  }
}
