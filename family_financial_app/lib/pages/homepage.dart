import 'package:family_financial_app/models/drawer_item.dart';
import 'package:family_financial_app/drawer.dart';
import 'package:family_financial_app/pages/accounts_page.dart';
import 'package:family_financial_app/pages/categories_page.dart';
import 'package:family_financial_app/pages/overview_page.dart';
import 'package:family_financial_app/pages/transactions_page.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  static const currentKey = 'Homepage';
  final String title = 'Home';

  const Homepage() : super(key: const Key(currentKey));

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<ListTile> drawerWidgets = [];
  List<DrawerItem> drawerItems = [];

  final ValueNotifier<String> _currentPageAlias = ValueNotifier<String>(
    'accounts',
  );

  _HomepageState() {
    // Initialize any necessary data or state here

    drawerItems = <DrawerItem>[
      // DrawerItem(
        // alias: 'overview',
        // title: 'Overview',
        // icon: Icons.dashboard,
        // initPage: () => OverviewPage(context),
      // ),
      // DrawerItem(
        // alias: 'transactions',
        // title: 'Transactions',
        // icon: Icons.receipt,
        // initPage: () => TransactionsPage(context),
      // ),
      DrawerItem(
        alias: 'accounts',
        title: 'Accounts',
        icon: Icons.wallet,
        initPage: () => AccountsPage(context),
      ),
      // DrawerItem(
        // alias: 'categories',
        // title: 'Categories',
        // icon: Icons.category,
        // initPage: () => CategoriesPage(context),
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: _currentPageAlias,
          builder: (context, value, child) {
            return Text(
              drawerItems.firstWhere((item) => item.alias == value).title,
            );
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _currentPageAlias,
        builder: (context, value, child) {
          return drawerItems
              .firstWhere((item) => item.alias == value)
              .initPage()
              .body();
        },
      ),
      drawer: MyDrawer(
        drawerItems: drawerItems,
        currentPageAlias: _currentPageAlias,
        key: const Key('AppDrawer'),
      ),
    );
  }
}
