import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';

class AccountsTableSource extends DataTableSource {
  final BuildContext context;
  final List<ItemAccount> accounts;
  final Function onRowLongPressed;
  final VoidCallback loadTable;
  late final Api api;

  AccountsTableSource({
    required this.context,
    required this.accounts,
    required this.onRowLongPressed,
    required this.loadTable,
  }) : api = Api(context);

  @override
  DataRow getRow(int index) {
    final account = accounts[index];
    return DataRow.byIndex(
      index: index,
      onLongPress: () => onRowLongPressed(account),
      cells: [
        DataCell(Text(account.name)),
        DataCell(Text(account.description ?? '')),
        DataCell(
          Center(
            child: Icon(
              Icons.circle,
              color: Utils.hexStringToColor(account.color),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(account.balance.toString()),
          ),
        ),
        DataCell(Text(account.createdAt.toString())),
        DataCell(Text(account.updatedAt.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => accounts.length;

  @override
  int get selectedRowCount => 0;
}
