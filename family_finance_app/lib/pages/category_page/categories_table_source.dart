import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';

class CategoriesTableSource extends DataTableSource {
  final BuildContext context;
  final List<ItemCategory> categories;
  final Function onRowLongPressed;
  final VoidCallback loadTable;
  final fontFamily = Icons.home.fontFamily;

  CategoriesTableSource({
    required this.context,
    required this.categories,
    required this.onRowLongPressed,
    required this.loadTable,
  });

  @override
  DataRow getRow(int index) {
    final category = categories[index];
    return DataRow.byIndex(
      index: index,
      onLongPress: () => onRowLongPressed(category),
      cells: [
        DataCell(
          Row(
            children: [
              Icon(
                IconData(category.icon, fontFamily: fontFamily),
                color: Utils.hexStringToColor(category.color),
              ),
              const SizedBox(width: 8.0),
              Text(category.name),
            ],
          ),
        ),
        DataCell(Text(category.description ?? '')),
        DataCell(Text(category.createdAt.toString())),
        DataCell(Text(category.createdBy.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categories.length;

  @override
  int get selectedRowCount => 0;
}
