import 'package:flutter/material.dart';

class AccountsPage extends Scaffold {
  static const currentKey = 'AccountsPage';
  final String title = 'Accounts';
  final BuildContext _context;

  const AccountsPage(BuildContext context) : _context = context, super(key: const Key(currentKey));

  @override
  PreferredSizeWidget? get appBar => AppBar(
    title: Text(title),
  );

  @override
  Widget? get body => Center(
    child: const Text('This is the Accounts page.'),
  );
}
