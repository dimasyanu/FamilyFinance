import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class DrawerItem {
  final String alias;
  final String title;
  final IconData icon;
  final MyPage Function() initPage;
  final bool newScreen;

  DrawerItem({
    required this.alias,
    required this.title,
    required this.icon,
    required this.initPage,
    this.newScreen = false,
  });
}