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
  List<ListTile> drawerWidgets = [];
  List<DrawerItem> drawerItems = [];
  final ValueNotifier<String> _currentPageAlias = ValueNotifier<String>(
    'overview',
  );

  _HomepageState() {
    // Initialize any necessary data or state here

    drawerItems = <DrawerItem>[
      DrawerItem(
        alias: 'overview',
        title: 'Overview',
        icon: Icons.dashboard,
        initPage: () => OverviewPage(context),
      ),
      //   DrawerItem(
      //     alias: 'transactions',
      //     title: 'Transactions',
      //     icon: Icons.receipt,
      //     page: TransactionsPage(context),
      //   ),
      DrawerItem(
        alias: 'accounts',
        title: 'Accounts',
        icon: Icons.wallet,
        initPage: () => AccountsPage(context),
      ),
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
    ];

    drawerWidgets = drawerItems.map((item) {
      if (!item.newScreen) {
        return ListTile(
          title: Text(item.title),
          leading: Icon(item.icon, color: Colors.green),
          selectedTileColor: Colors.green.shade100,
          selected: (() => item.alias == _currentPageAlias.value)(),
          onTap: () {
            if (_currentPageAlias.value == item.alias) return;
            _currentPageAlias.value = item.alias;
            Navigator.pop(context);
          },
        );
      }

      print('Creating new screen for ${item.alias}');
      return ListTile(
        title: Text(item.title),
        leading: Icon(item.icon, color: Colors.green),
        selectedTileColor: Colors.green.shade100,
        selected: item.alias == _currentPageAlias.value,
        onTap: () {
          if (item.alias == _currentPageAlias.value) {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: item.initPage().appBar,
                body: item.initPage().body,
              ),
            ),
          );
        },
      );
    }).toList();
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
              .body;
        },
      ),
      drawer: MyDrawer(drawerWidgets, key: const Key('AppDrawer')),
    );
  }
}
