import 'package:family_financial_app/models/drawer_item.dart';
import 'package:family_financial_app/pages/transactions_page.dart';
import 'package:flutter/material.dart';

import 'pages/accounts_page.dart';
import 'pages/categories_page.dart';
import 'pages/overview_page.dart';
import 'pages/settings_page.dart';

class MyDrawer extends Drawer {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerMenus = <DrawerItem>[
      DrawerItem(
        title: 'Overview',
        icon: Icons.dashboard,
        page: const OverviewPage()
      ),
      DrawerItem(
        title: 'Transactions',
        icon: Icons.receipt,
        page: const TransactionsPage()
      ),
      DrawerItem(
        title: 'Accounts',
        icon: Icons.wallet,
        page: const AccountsPage(),
      ),
      DrawerItem(
        title: 'Categories',
        icon: Icons.category,
        page: const CategoriesPage(),
      ),
      DrawerItem(
        title: 'Settings',
        icon: Icons.settings,
        page: const SettingsPage()
      ),
    ];

    final drawerItems = <Widget>[
      const DrawerHeader(
        decoration: BoxDecoration(color: Colors.green),
        child: Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
        ),
      ),
    ];

    drawerItems.addAll(drawerMenus.map((item) {
      return ListTile(
        title: Text(item.title),
        leading: Icon(item.icon, color: Colors.green),
        selectedTileColor: Colors.green.shade100,
        selected: item.page.key == context.widget.key,
        onTap: () {
          if (context.widget.key == item.page.key) {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => item.page),
          );
        },
      );
    }).toList());

    drawerItems.add(const Divider());
    
    drawerItems.add(
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomLeft,
          child: ListTile(
            title: const Text('Logout'),
            leading: Icon(Icons.logout, color: Colors.red),
            textColor: Colors.red,
            onTap: () {
              // Handle logout action
            },
          ),
        ),
      ),
    );

    return Drawer(
      child: ListView(
        children: drawerItems,
      ),

    );
  }
}
