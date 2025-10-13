import 'package:family_financial_app/components/row_action.dart';
import 'package:flutter/material.dart';

class BottomActionMenu extends StatelessWidget {
  final Widget itemDetail;
  final List<RowAction> actions;

  const BottomActionMenu({
    super.key,
    required this.itemDetail,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(8.0),
      padding: null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 24, 8, 48),
            child: itemDetail,
          ),
          BottomNavigationBar(
            items: actions.map((action) {
              return BottomNavigationBarItem(
                icon: action.icon,
                label: action.label,
                backgroundColor: action.backgroundColor,
              );
            }).toList(),
            onTap: (index) {
              if (index >= actions.length) return;
              actions[index].onPressed();
            },
          ),
        ],
      ),
    );
  }
}
