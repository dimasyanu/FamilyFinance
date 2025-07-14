import 'package:flutter/material.dart';

import '../my_drawer.dart';

class CategoriesPage extends StatefulWidget {
  static const currentKey = 'CategoriesPage';
  final String title = 'Categories';

  const CategoriesPage() : super(key: const Key(currentKey));

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: const Text('This is the Categories page.'),
      ),
      drawer: MyDrawer(key: const Key(CategoriesPage.currentKey),),
    );
  }
}