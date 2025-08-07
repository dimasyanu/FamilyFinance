import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:flutter/material.dart';

class TransactionsListItem extends StatelessWidget {
  final ItemTransaction transaction;

  const TransactionsListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.description),
      subtitle: Text(transaction.transactionDate),
      trailing: Text(transaction.amount.toString()),
    );
  }
}
