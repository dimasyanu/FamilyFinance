import 'package:flutter/material.dart';

abstract class MyPage {
  late final AppBar appBar;
  final String route;
  final String title;
  late final ThemeData? theme;
  bool _isMounted = false;
  late void Function(VoidCallback) _setState;

  MyPage(BuildContext context, {required this.route, required this.title}) {
    theme = Theme.of(context);
    appBar = AppBar(
      title: appBarTitle(context) ?? Text(title),
      backgroundColor: appBarBackgroundColor() ?? theme!.colorScheme.surface,
    );
  }

  Widget build(BuildContext context);
  Widget? appBarTitle(BuildContext context) => null;
  Color? appBarBackgroundColor() => null;
  Color? appBarForegroundColor() => null;
  Future<void> onMounted(BuildContext context);
  FloatingActionButton? floatingActionButton(BuildContext context) => null;
  FloatingActionButtonLocation? floatingActionButtonLocation(
    BuildContext context,
  ) => null;
  void dispose() {
    _isMounted = false;
  }

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
    if (!_isMounted) return;
    _setState(fn);
  }
}
