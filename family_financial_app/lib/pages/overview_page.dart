import 'package:flutter/material.dart';

class OverviewPage extends Scaffold {
  static const currentKey = 'OverviewPage';
  final String title = 'Overview';

  final BuildContext _context;

  const OverviewPage(BuildContext context) : _context = context, super(key: const Key(currentKey));

  @override
  PreferredSizeWidget? get appBar => AppBar(
    backgroundColor: Theme.of(_context).colorScheme.inversePrimary,
    title: Text(title),
  );

  @override
  Widget? get body => Center(
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
  );
}
