import 'package:flutter/material.dart';
import '../my_drawer.dart';

class TransactionsPage extends StatefulWidget {
  static const currentKey = 'TransactionsPage';
  final String title = 'Transactions';

  const TransactionsPage() : super(key: const Key(currentKey));

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Center(
        child: Text('This is the Transactions page.'),
      ),
      drawer: MyDrawer(key: const Key(TransactionsPage.currentKey),),
    );
  }
}