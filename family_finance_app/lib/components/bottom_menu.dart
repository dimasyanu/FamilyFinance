import 'package:family_financial_app/components/row_action.dart';
import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  final List<RowAction> items;

  const BottomMenu({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(8.0),
      padding: null,
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Container(
                padding: null,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: items.map((item) {
                      return ElevatedButton(
                        child: Text(item.label),
                        onPressed: () {},
                      );
                    }).toList(),
                  ),
                ),
              ),
              // type: BottomNavigationBarType.fixed,
            ),
          ),
        ],
      ),
    );
  }
}
