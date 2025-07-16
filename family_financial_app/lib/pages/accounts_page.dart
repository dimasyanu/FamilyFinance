import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class AccountsPage extends MyPage {
  static const currentKey = 'AccountsPage';
  static const String title = 'Accounts';

  AccountsPage(BuildContext context) : super(appBar: AppBar(title: Text(title)));

  @override
  Widget body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('This is the Accounts page.'),
        ],
      ),
    );
  }

  @override
  void onMounted() {
    // Perform any additional setup or state initialization here
    debugPrint('AccountsPage mounted');
  }
}
