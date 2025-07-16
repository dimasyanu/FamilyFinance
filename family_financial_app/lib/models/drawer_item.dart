import 'package:flutter/material.dart';

class DrawerItem {
  final String alias;
  final String title;
  final IconData icon;
  final StatefulWidget page;
  final bool newScreen;

  DrawerItem({
    required this.alias,
    required this.title,
    required this.icon,
    required this.page,
    this.newScreen = false,
  });
}