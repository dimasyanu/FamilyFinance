import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class AccountsPage extends MyPage {
  static const currentKey = 'AccountsPage';
  static const String title = 'Accounts';
  final BuildContext _context;

  AccountsPage(BuildContext context) : _context = context, 
  super(appBar: AppBar(title: Text(title)), body: Center(child: const Text('This is the Accounts page.')));
}
