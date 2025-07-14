import 'package:flutter/material.dart';

import '../my_drawer.dart';

class SettingsPage extends StatefulWidget {
  static const currentKey = 'SettingsPage';
  final String title = 'Settings';

  const SettingsPage() : super(key: const Key(currentKey));

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: const Text('This is the Settings page.'),
      ),
      drawer: MyDrawer(key: const Key(SettingsPage.currentKey),),
    );
  }
}