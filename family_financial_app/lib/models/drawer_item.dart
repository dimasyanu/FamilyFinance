import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class DrawerItem {
  final String route;
  final String title;
  final IconData icon;
  final MyPage Function() page;

  DrawerItem({
    required this.route,
    required this.title,
    required this.icon,
    required this.page,
  });
}