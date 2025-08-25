import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsDetail extends StatelessWidget {
  final ItemTransaction transaction;

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              IconData(transaction.categoryIcon, fontFamily: 'MaterialIcons'),
              color: Utils.hexStringToColor(transaction.categoryColor),
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              transaction.category,
              style: GoogleFonts.interTight(fontSize: 10),
            ),
            SizedBox(width: 8),
            Text('|', style: TextStyle(color: Colors.grey)),
            SizedBox(width: 8),
            Icon(
              Icons.circle,
              color: Utils.hexStringToColor(transaction.accountColor),
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              transaction.account,
              style: GoogleFonts.interTight(fontSize: 10),
            ),
          ],
        ),
        (transaction.notes != null && transaction.notes!.isNotEmpty)
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  transaction.notes!,
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              )
            : SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
          child: Text(
            (transaction.transactionType == TransactionType.expense
                    ? '- '
                    : '') +
                Utils.formatCurrency(transaction.amount),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: transaction.transactionType == TransactionType.expense
                  ? Colors.red.shade400
                  : transaction.transactionType == TransactionType.income
                  ? Colors.green.shade400
                  : Colors.blue.shade400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            transaction.transactionDate,
            style: GoogleFonts.interTight(fontSize: 12, color: Colors.grey),
          ),
        ),
        Text(
          transaction.transactionTime,
          style: GoogleFonts.interTight(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
