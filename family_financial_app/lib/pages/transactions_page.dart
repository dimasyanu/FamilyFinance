import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends MyPage {
  static const currentKey = 'TransactionsPage';
  static const String title = 'Transactions';

  TransactionsPage(BuildContext context) : super(appBar: AppBar(title: Text(title)));

  @override
  Widget body() {
    return Center(
      child: Text('This is the Transactions page.'),
    );
  }

  @override
  void onMounted() {
    // Perform any additional setup or state initialization here
    debugPrint('TransactionsPage mounted');
  }
}
