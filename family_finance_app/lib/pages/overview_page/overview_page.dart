import 'package:family_financial_app/components/overview/month_expanses_bar_chart.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:flutter/material.dart';

class OverviewPage extends MyPage {
  ValueNotifier<int> counter = ValueNotifier<int>(0);

  OverviewPage(super.context) : super(route: 'OverviewPage', title: 'Overview');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[MonthExpansesBarChart()],
    );
  }

  @override
  Future<void> onMounted(BuildContext context) async {
    // Perform any additional setup or state initialization here
    debugPrint('OverviewPage mounted');
  }

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }
}
