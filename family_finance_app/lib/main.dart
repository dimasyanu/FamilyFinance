import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/login.dart';
import 'package:family_financial_app/plugins/store_mobile.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:family_financial_app/plugins/store_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

final ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Utils.hexStringToColor('#40A2E3'),
  onPrimary: Utils.hexStringToColor('#FFFFFF'),
  secondary: Utils.hexStringToColor('#BBE2EC'),
  onSecondary: Utils.hexStringToColor('#333333'),
  tertiary: Utils.hexStringToColor(''),
  onTertiary: Utils.hexStringToColor('#0D9276'),
  error: Utils.hexStringToColor('#F44336'),
  onError: Utils.hexStringToColor('#FFFFFF'),
  surface: Utils.hexStringToColor('#FFF6E9'),
  onSurface: Utils.hexStringToColor('#373737'),
  surfaceDim: Utils.hexStringToColor('#EDEDED'),
);

final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Utils.hexStringToColor('#40A2E3'),
  onPrimary: Utils.hexStringToColor('#FFFFFF'),
  secondary: Utils.hexStringToColor('#BBE2EC'),
  onSecondary: Utils.hexStringToColor('#333333'),
  tertiary: Utils.hexStringToColor(''),
  onTertiary: Utils.hexStringToColor('#0D9276'),
  error: Utils.hexStringToColor('#F44336'),
  onError: Utils.hexStringToColor('#FFFFFF'),
  surface: Utils.hexStringToColor('#373737'),
  onSurface: Utils.hexStringToColor('#FFFFFF'),
  surfaceDim: Utils.hexStringToColor('#2C2C2C'),
);

Future main() async {
  await dotenv.load(fileName: '.env');

  if (kIsWeb) await initLocalStorage();
  final Store store = kIsWeb ? StoreWeb() : StoreMobile();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => store)],
      child: FamilyFinancialApp(store: store),
    ),
  );
}

class FamilyFinancialApp extends StatelessWidget {
  final Store store;

  const FamilyFinancialApp({super.key, required this.store});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<Store>(context);
    store.reloadThemeMode().whenComplete(() {});

    return MaterialApp(
      title: 'Family Financial',
      theme: ThemeData(
        colorScheme: appColorScheme,
        fontFamily: 'MarlinSoftBasic',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'MarlinSoftBasic',
        colorScheme: darkColorScheme,
      ),
      themeMode: store.themeMode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      home: Login(), // Use Login widget as the home page
    );
  }
}
