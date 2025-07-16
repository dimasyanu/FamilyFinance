import 'package:flutter/material.dart';

class CategoriesPage extends Scaffold {
  static const currentKey = 'CategoriesPage';
  final String title = 'Categories';
  final BuildContext _context;

  const CategoriesPage(BuildContext context) : _context = context, super(key: const Key(currentKey));

  @override
  PreferredSizeWidget? get appBar => AppBar(
    title: Text(title),
  );

  @override
  Widget? get body => Center(
    child: const Text('This is the Categories page.'),
  );
}
