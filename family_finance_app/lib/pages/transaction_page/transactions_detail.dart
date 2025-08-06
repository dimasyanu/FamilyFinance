import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/responses/dto_transaction.dart';
import 'package:flutter/material.dart';

class TransactionsDetail extends StatelessWidget {
  final DtoTransaction transaction;

  const TransactionsDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            transaction.description,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Builder(
          builder: (context) {
            switch (transaction.transactionType) {
              case TransactionType.expense:
                return Icon(Icons.arrow_downward, color: Colors.red);
              case TransactionType.income:
                return Icon(Icons.arrow_upward, color: Colors.green);
              case TransactionType.transfer:
                return Icon(Icons.swap_horiz, color: Colors.blue);
              default:
                return Icon(Icons.help, color: Colors.grey);
            }
          },
        ),
        Text(transaction.category.name),
        Text('Created: ${transaction.createdAt}'),
        Text('Updated: ${transaction.updatedAt}'),
      ],
    );
  }
}
