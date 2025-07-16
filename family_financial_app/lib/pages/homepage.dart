import 'package:family_financial_app/models/drawer_item.dart';
import 'package:family_financial_app/my_drawer.dart';
import 'package:family_financial_app/pages/accounts_page.dart';
import 'package:family_financial_app/pages/categories_page.dart';
import 'package:family_financial_app/pages/overview_page.dart';
import 'package:family_financial_app/pages/settings_page.dart';
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

  List<Widget> drawerWidgets = [];
  List<DrawerItem> drawerItems = [];
  String currentPageAlias = 'overview';

  _HomepageState() {
    // Initialize any necessary data or state here

    // drawerItems = <DrawerItem>[
    //   DrawerItem(
    //     alias: 'overview',
    //     title: 'Overview',
    //     icon: Icons.dashboard,
    //     page: OverviewPage(context),
    //   ),
    //   DrawerItem(
    //     alias: 'transactions',
    //     title: 'Transactions',
    //     icon: Icons.receipt,
    //     page: TransactionsPage(context),
    //   ),
    //   DrawerItem(
    //     alias: 'accounts',
    //     title: 'Accounts',
    //     icon: Icons.wallet,
    //     page: AccountsPage(context),
    //   ),
    //   DrawerItem(
    //     alias: 'categories',
    //     title: 'Categories',
    //     icon: Icons.category,
    //     page: CategoriesPage(context),
    //   ),
    //   DrawerItem(
    //     alias: 'settings',
    //     title: 'Settings',
    //     icon: Icons.settings,
    //     page: const SettingsPage(),
    //     newScreen: true, // This indicates that the settings page should be opened in a new screen
    //   ),
    // ];

    // drawerWidgets = drawerItems.map((item) {
    //   if (!item.newScreen) {
    //     return ListTile(
    //       title: Text(item.title),
    //       leading: Icon(item.icon, color: Colors.green),
    //       selectedTileColor: Colors.green.shade100,
    //       selected: item.page.key == context.widget.key,
    //       onTap: () {
    //         if (currentPageAlias == item.alias) {
    //           return;
    //         }
    //         currentPageAlias = item.alias;
    //       },
    //     );
    //   }

    //   return ListTile(
    //     title: Text(item.title),
    //     leading: Icon(item.icon, color: Colors.green),
    //     selectedTileColor: Colors.green.shade100,
    //     selected: item.page.key == context.widget.key,
    //     onTap: () {
    //       if (context.widget.key == item.page.key) {
    //         return;
    //       }
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => item.page),
    //       );
    //     },
    //   );
    // }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const String page = 'overview';
    return AccountsPage(context);

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(drawerItems.firstWhere((item) => item.alias == page).title),
    //   ),
    //   body: drawerItems.firstWhere((item) => item.alias == page).page,
    //   drawer: MyDrawer(drawerWidgets, key: const Key('AppDrawer')),
    // );
  }
}