import 'package:flutter/material.dart';

import '../my_drawer.dart';

class AccountsPage extends StatefulWidget {
  static const currentKey = 'AccountsPage';
  final String title = 'Accounts';

  const AccountsPage() : super(key: const Key(currentKey));

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: const Text('This is the Accounts page.'),
      ),
      drawer: MyDrawer(key: Key(AccountsPage.currentKey),),
    );
  }
}