import 'package:flutter/material.dart';

abstract class MyPage {
  late final AppBar appBar;
  final String route;
  final String title;
  late void Function(VoidCallback) _setState;

  MyPage(BuildContext context, {required this.route, required this.title}) {
    appBar = AppBar(title: Text(title));
    onMounted(context);
  }

  Widget body(BuildContext context);
  void onMounted(BuildContext context);
  FloatingActionButton? floatingActionButton(BuildContext context) => null;
  void dispose() {}

  void initState(void Function(VoidCallback) setState) {
    _setState = setState;
  }

  void setState(VoidCallback fn) {
    _setState(fn);
  }
}
