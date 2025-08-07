import 'package:flutter/material.dart';

class TransactionsBottomNavigationBar {
  final Color foregroundColor;
  final TabController tabController;

  TransactionsBottomNavigationBar({
    required this.tabController,
    required this.foregroundColor,
  });

  Widget? getNavigationBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        tabs: [
          Tab(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sync_alt, color: foregroundColor, size: 18),
                const SizedBox(width: 8.0),
                Text('All'),
              ],
            ),
          ),
          Tab(
            child: Row(
              children: [
                Icon(Icons.arrow_upward, color: foregroundColor, size: 18),
                Text('Expenses'),
              ],
            ),
          ),
          Tab(
            child: Row(
              children: [
                Icon(Icons.arrow_downward, color: foregroundColor, size: 18),
                Text('Income'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
