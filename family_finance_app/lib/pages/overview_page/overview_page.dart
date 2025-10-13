import 'package:family_financial_app/components/overview/month_expanses_bar_chart.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class OverviewPage extends MyPage {
  ValueNotifier<int> counter = ValueNotifier<int>(0);

  OverviewPage(super.context) : super(route: 'OverviewPage', title: 'Overview');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[MonthExpansesBarChart()],
      ),
    );
  }

  @override
  Future<void> onMounted(BuildContext context) async {}

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }
}
