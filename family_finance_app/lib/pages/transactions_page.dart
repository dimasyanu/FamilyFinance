import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends MyPage {
  TransactionsPage(BuildContext context) : super(route: 'TransactionsPage', title: 'Transactions');

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
