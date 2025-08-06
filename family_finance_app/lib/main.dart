import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/login.dart';
import 'package:family_financial_app/plugins/mobile_store.dart';
import 'package:family_financial_app/plugins/web_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

Future main() async {
  await dotenv.load(fileName: '.env');

  if (kIsWeb) await initLocalStorage();
  final Store store = kIsWeb ? WebStore() : MobileStore();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => store)],
      child: const FamilyFinancialApp(),
    ),
  );
}

class FamilyFinancialApp extends StatelessWidget {
  const FamilyFinancialApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Financial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: Login(), // Use Login widget as the home page
    );
  }
}
