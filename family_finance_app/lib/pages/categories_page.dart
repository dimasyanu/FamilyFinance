import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends MyPage {
  CategoriesPage(super.context)
    : super(route: 'CategoriesPage', title: 'Categories');

  @override
  Widget body(BuildContext context) {
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
  void onMounted(BuildContext context) {
    // Perform any additional setup or state initialization here
    debugPrint('CategoriesPage mounted');
  }
}
