import 'package:flutter/material.dart';

abstract class MyPage {
  late final AppBar appBar;
  final String route;
  final String title;

  MyPage({required this.route, required this.title}) {
    appBar = AppBar(title: Text(title));
    onMounted();
  }

  Widget body();
  void onMounted();
  FloatingActionButton? floatingActionButton(BuildContext context) => null;
  void dispose() {}
}