import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class OverviewPage extends MyPage {
  static const currentKey = 'OverviewPage';
  static const String title = 'Overview';

  ValueNotifier<int> counter = ValueNotifier<int>(0);

  OverviewPage(BuildContext context) : super(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
    ),
  );

  @override
  Widget body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('This is the Overview page.'),
          ValueListenableBuilder<int>(
            valueListenable: counter,
            builder: (context, value, child) {
              return Text(value.toString());
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              counter.value++;
            },
            child: const Text('Action Button'),
          ),
        ],
      ),
    );
  }

  @override
  void onMounted() {
    // Perform any additional setup or state initialization here
    debugPrint('OverviewPage mounted');
  }
}
