import 'package:flutter/material.dart';

class TransactionsPage extends Scaffold {
  static const currentKey = 'TransactionsPage';
  final String title = 'Transactions';

  const TransactionsPage(BuildContext context) : super(key: const Key(currentKey));

  @override
  PreferredSizeWidget? get appBar => AppBar(
    title: Text(title),
  );

  @override
  Widget? get body => Center(
    child: Text('This is the Transactions page.'),
  );
}
