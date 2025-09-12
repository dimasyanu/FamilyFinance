import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/login.dart';
import 'package:family_financial_app/plugins/mobile_store.dart';
import 'package:family_financial_app/plugins/utils.dart';
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

final ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Utils.hexStringToColor('#40A2E3'),
  onPrimary: Utils.hexStringToColor('#FFFFFF'),
  secondary: Utils.hexStringToColor('#BBE2EC'),
  tertiary: Utils.hexStringToColor(''),
  onTertiary: Utils.hexStringToColor('#0D9276'),
  onSecondary: Utils.hexStringToColor('#FFFFFF'),
  error: Utils.hexStringToColor('#F44336'),
  onError: Utils.hexStringToColor('#FFFFFF'),
  surface: Utils.hexStringToColor('#FFF6E9'),
  onSurface: Utils.hexStringToColor('#373737'),
);

class FamilyFinancialApp extends StatelessWidget {
  const FamilyFinancialApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Financial',
      theme: ThemeData(
        colorScheme: appColorScheme,
        fontFamily: 'MarlinSoftBasic',
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      home: Login(), // Use Login widget as the home page
    );
  }
}
