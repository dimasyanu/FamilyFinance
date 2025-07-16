import 'package:flutter/material.dart';

abstract class MyPage {
  final AppBar appBar;

  MyPage({required this.appBar}) {
    onMounted();
  }

  Widget body();
  void onMounted();
}