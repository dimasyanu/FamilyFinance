import 'package:flutter/material.dart';

abstract class MyPage {
  late final AppBar appBar;
  final String route;
  final String _title;
  String get title => _title;
  bool _isMounted = false;
  late void Function(VoidCallback) _setState;

  MyPage(BuildContext context, {required this.route, required String title})
    : _title = title {
    final theme = Theme.of(context);
    appBar = AppBar(
      title: appBarTitle(context) ?? Text(_title),
      backgroundColor:
          appBarBackgroundColor(context) ?? theme.colorScheme.surface,
    );
  }

  Widget build(BuildContext context);
  Widget? appBarTitle(BuildContext context) => null;
  Color? appBarBackgroundColor(BuildContext context) => null;
  Color? appBarForegroundColor(BuildContext context) => null;
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
