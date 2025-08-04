import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:flutter/material.dart';

class AccountDetail extends StatelessWidget {
  final ItemAccount account;

  const AccountDetail({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            account.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Text(account.description ?? ''),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Balance: ${account.balance}',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Text('Created: ${account.createdAt}'),
        Text('Updated: ${account.updatedAt}'),
      ],
    );
  }
}
