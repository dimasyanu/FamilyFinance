import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/login.dart';
import 'package:family_financial_app/models/drawer_item.dart';
import 'package:family_financial_app/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDrawer extends Drawer {
  final List<DrawerItem> drawerItems;
  final ValueNotifier<String> currentPageRoute;

  const MyDrawer({
    required this.drawerItems,
    required this.currentPageRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Center(
              child: CircleAvatar(
                radius: 50,
                // backgroundImage: AssetImage('../assets/images/profile.png'),
              ),
            ),
          ),

          ...drawerItems.map(
            (item) => ListTile(
              title: Text(item.title),
              leading: Icon(item.icon, color: Colors.green),
              selectedTileColor: Colors.green.shade100,
              selected: item.route == currentPageRoute.value,
              onTap: () {
                if (currentPageRoute.value == item.route) return;
                currentPageRoute.value = item.route;
                Navigator.pop(context);
              },
            ),
          ),

          const Divider(),

          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),

          const Divider(),

          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomLeft,
              child: ListTile(
                title: const Text('Logout'),
                leading: Icon(Icons.logout, color: Colors.red),
                textColor: Colors.red,
                onTap: () {
                  context.read<Store>().logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
