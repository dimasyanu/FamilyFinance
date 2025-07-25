import 'package:flutter/material.dart';

class RowAction {
  final Icon icon;
  final String label;
  final VoidCallback onPressed;

  RowAction({required this.icon, required this.label, required this.onPressed});
}
