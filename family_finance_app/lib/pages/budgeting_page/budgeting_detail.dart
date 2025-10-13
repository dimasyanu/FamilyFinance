import 'package:family_financial_app/models/responses/item_budget.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';

class BudgetingDetail extends StatelessWidget {
  final ItemBudget budget;

  const BudgetingDetail({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          budget.period,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconData(budget.category.icon, fontFamily: 'MaterialIcons'),
                color: Utils.hexStringToColor(budget.category.color),
              ),
              const SizedBox(width: 8.0),
              Text(budget.category.name),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        Text(Utils.formatCurrency(budget.amount)),
      ],
    );
  }
}
