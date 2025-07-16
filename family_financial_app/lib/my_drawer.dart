import 'package:flutter/material.dart';

class MyDrawer extends Drawer {
  final List<ListTile> drawerItems;

  const MyDrawer(this.drawerItems, {super.key});

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('../assets/images/profile.png'),
              ),
            ),
          ),

          ...drawerItems,

          const Divider(),

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
        ],
      ),

    );
  }
}
