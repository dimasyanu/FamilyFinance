import 'package:flutter/material.dart';
import 'pages/overview_page.dart';

void main() {
  runApp(const FamilyFinancialApp());
}

class FamilyFinancialApp extends StatelessWidget {
  const FamilyFinancialApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Financial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const OverviewPage(),
    );
  }
}
