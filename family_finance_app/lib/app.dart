import 'package:family_financial_app/models/drawer_item.dart';
import 'package:family_financial_app/drawer.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/pages/account_page/accounts_page.dart';
import 'package:family_financial_app/pages/budgeting_page/budgeting_page.dart';
import 'package:family_financial_app/pages/category_page/categories_page.dart';
import 'package:family_financial_app/pages/overview_page/overview_page.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  static const currentKey = 'homepage';

  const App() : super(key: const Key(currentKey));

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<ListTile> drawerWidgets = [];
  late final List<DrawerItem> drawerItems;

  final _currentPageRoute = ValueNotifier<String>('overview');
  final _currentMenu = ValueNotifier<DrawerItem?>(null);
  final _currentPage = ValueNotifier<MyPage?>(null);

  _AppState() {
    // Initialize any necessary data or state here

    drawerItems = <DrawerItem>[
      DrawerItem(
        route: 'overview',
        icon: Icons.dashboard,
        page: () => OverviewPage(context),
      ),
      DrawerItem(
        route: 'transactions',
        icon: Icons.receipt,
        page: () => TransactionsPage(context),
      ),
      DrawerItem(
        route: 'accounts',
        icon: Icons.wallet,
        page: () => AccountsPage(context),
      ),
      DrawerItem(
        route: 'categories',
        icon: Icons.category,
        page: () => CategoriesPage(context),
      ),
      DrawerItem(
        route: 'budgeting',
        icon: Icons.attach_money,
        page: () => BudgetingPage(context),
      ),
    ];

    _currentPageRoute.addListener(() {
      setState(setPageState);
    });
    // _currentPageRoute.value = 'accounts';
  }

  void setPageState() {
    _currentMenu.value = drawerItems.firstWhere(
      (item) => item.route == _currentPageRoute.value,
      orElse: () => drawerItems.first,
    );
    _currentPage.value?.dispose();
    _currentPage.value = _currentMenu.value?.page();
    _currentPage.value?.initState(setState);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMenu.value == null) {
      setPageState(); // Ensure the current menu is set
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            _currentPage.value?.appBarTitle(context) ??
            Text(_currentPage.value?.title ?? 'App'),
        backgroundColor:
            _currentPage.value?.appBarBackgroundColor(context) ??
            theme.colorScheme.surfaceDim,
        foregroundColor:
            _currentPage.value?.appBarForegroundColor(context) ??
            theme.colorScheme.onSurface,
      ),
      body: ValueListenableBuilder(
        valueListenable: _currentPage,
        builder: (context, value, child) {
          return value?.body(context) ?? Center(child: Text('Not found'));
        },
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _currentPage,
        builder: (context, value, child) {
          return value?.floatingActionButton(context) ?? SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation:
          _currentPage.value?.floatingActionButtonLocation(context) ??
          FloatingActionButtonLocation.endFloat,
      drawer: MyDrawer(
        drawerItems: drawerItems,
        currentPageRoute: _currentPageRoute,
        key: const Key('AppDrawer'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    _currentPageRoute.dispose();
    _currentMenu.dispose();
    _currentPage.dispose();
    super.dispose();
  }
}
