import 'package:flutter/material.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: const Text('This is the Settings page.'),
      ),
    );
  }
}