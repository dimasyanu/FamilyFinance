import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/profile_picture.dart';
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
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    const borderColor = Color.fromARGB(255, 197, 197, 197);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 40, bottom: 30),
            color: theme.colorScheme.primary,
            child: FutureBuilder(
              future: context.read<Store>().getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      ProfilePicture(
                        username: snapshot.data!.username,
                        radius: 75,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        snapshot.data!.name,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),

          ...drawerItems.map(
            (item) => ListTile(
              title: Text(item.title),
              leading: Icon(item.icon, color: theme.colorScheme.primary),
              selectedTileColor: theme.colorScheme.secondary,
              selectedColor: theme.colorScheme.onSecondary,
              selected: item.route == currentPageRoute.value,
              onTap: () {
                navigator.pop();
                if (currentPageRoute.value == item.route) return;
                currentPageRoute.value = item.route;
              },
            ),
          ),

          const Divider(color: borderColor),

          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings, color: Colors.grey),
            onTap: () {
              navigator.push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),

          const Divider(color: borderColor),

          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomLeft,
              child: ListTile(
                title: const Text('Logout'),
                leading: Icon(Icons.logout, color: Colors.red),
                textColor: Colors.red,
                onTap: () {
                  context.read<Store>().logout();
                  navigator.pushReplacement(
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
