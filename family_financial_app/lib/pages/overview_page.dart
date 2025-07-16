import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class OverviewPage extends MyPage {
  static const currentKey = 'OverviewPage';
  static const String title = 'Overview';

  final BuildContext _context;

  OverviewPage(BuildContext context) : _context = context, super(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('This is the Overview page.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Action for button
            },
            child: const Text('Action Button'),
          ),
        ],
      ),
    ),
  );
}
