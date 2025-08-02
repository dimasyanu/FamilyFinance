import 'package:family_financial_app/models/responses/item_budget.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';

class BudgetingTableSource extends DataTableSource {
  final BuildContext context;
  final List<ItemBudget> budgets;
  final Function onRowLongPressed;
  final fontFamily = Icons.money.fontFamily;

  BudgetingTableSource({
    required this.context,
    required this.budgets,
    required this.onRowLongPressed,
  });

  @override
  DataRow getRow(int index) {
    final budget = budgets[index];
    return DataRow.byIndex(
      index: index,
      onLongPress: () => onRowLongPressed(budget),
      cells: [
        DataCell(Text('${Utils.getMonthName(budget.month)} ${budget.year}')),
        DataCell(Text(budget.category.name)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => budgets.length;

  @override
  int get selectedRowCount => 0;
}
