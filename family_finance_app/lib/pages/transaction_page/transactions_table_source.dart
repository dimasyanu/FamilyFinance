import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';

class TransactionsTableSource extends DataTableSource {
  final BuildContext context;
  final List<ItemTransaction> transactions;
  final Function onRowLongPressed;
  final fontFamily = Icons.home.fontFamily;

  TransactionsTableSource({
    required this.context,
    required this.transactions,
    required this.onRowLongPressed,
  });

  @override
  DataRow getRow(int index) {
    final transaction = transactions[index];
    return DataRow.byIndex(
      index: index,
      onLongPress: () => onRowLongPressed(transaction),
      cells: [
        DataCell(Text(transaction.description)),
        DataCell(
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
        ),
        DataCell(Text(transaction.account)),
        DataCell(Text(transaction.category)),
        DataCell(Text(Utils.formatCurrency(transaction.amount))),
        DataCell(Text(transaction.transactionDate)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => transactions.length;

  @override
  int get selectedRowCount => 0;
}
