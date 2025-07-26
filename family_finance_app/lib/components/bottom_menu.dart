import 'package:family_financial_app/components/row_action.dart';
import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  final Widget itemDetail;
  final List<RowAction> actions;

  const BottomMenu({super.key, required this.itemDetail, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(8.0),
      padding: null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: itemDetail,
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: BottomNavigationBar(
                items: actions.map((item) {
                  return BottomNavigationBarItem(
                    icon: item.icon,
                    label: item.label,
                  );
                }).toList(),
                onTap: (index) {
                  if (index >= actions.length) return;
                  actions[index].onPressed();
                },
              ),
              // type: BottomNavigationBarType.fixed,
            ),
          ),
        ],
      ),
    );
  }
}
