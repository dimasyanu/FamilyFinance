import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends MyPage {
  static const currentKey = 'CategoriesPage';
  static const String title = 'Categories';

  CategoriesPage(BuildContext context) : super(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
  );

  @override
  Widget body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('This is the Categories page.'),
          ElevatedButton(
            onPressed: () {
              // Action for button
            },
            child: const Text('Action Button'),
          ),
        ],
      ),
    );
  }

  @override
  void onMounted() {
    // Perform any additional setup or state initialization here
    debugPrint('CategoriesPage mounted');
  }
}
