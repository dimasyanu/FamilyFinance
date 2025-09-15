import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_bottom_navigation_bar.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_list_view.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_form_page.dart';
import 'package:family_financial_app/plugins/api_transactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    hide RefreshIndicatorState;

class TransactionsPage extends MyPage {
  final ApiTransactions api;
  final Store store;
  final ScaffoldMessengerState messenger;

  final transactions = ValueNotifier<List<ItemTransaction>>([]);
  final totalCount = ValueNotifier<int>(0);
  final pageSize = ValueNotifier<int>(10);
  final page = ValueNotifier<int>(1);
  final isError = ValueNotifier<bool>(false);
  RefreshController? refreshController;

  final allTransactionsController = TransactionsListViewController();
  final expansesTransactionsController = TransactionsListViewController();
  final incomesTransactionsController = TransactionsListViewController();
  TransactionsListViewController? _currentController;

  TabController? _tabController;

  static const headerStyle = TextStyle(fontWeight: FontWeight.bold);

  final List<DataColumn> columns = const [
    DataColumn(
      label: Row(
        children: [
          SizedBox(width: 16.0),
          Text('Description', style: headerStyle),
        ],
      ),
    ),
    DataColumn(label: Text('Type', style: headerStyle)),
    DataColumn(label: Text('Account', style: headerStyle)),
    DataColumn(label: Text('Category', style: headerStyle)),
    DataColumn(label: Text('Amount', style: headerStyle)),
    DataColumn(label: Text('Transaction Date', style: headerStyle)),
  ];

  TransactionsPage(super.context)
    : store = context.read<Store>(),
      messenger = ScaffoldMessenger.of(context),
      api = ApiTransactions(context),
      super(route: 'TransactionsPage', title: 'Transactions');

  @override
  Color? appBarForegroundColor(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.primary;
    }
    return Colors.blue.shade700;
  }

  @override
  Color? appBarBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surfaceDim;
  }

  @override
  Widget? appBarTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      key: const Key('appBarTitle'),
      children: [
        Icon(Icons.category, color: appBarForegroundColor(context)),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: TextStyle(color: appBarForegroundColor(context), fontSize: 18),
        ),
      ],
    );
  }

  @override
  Future<void> onMounted(BuildContext context) async {
    // allTransactionsController.invoke(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _tabController = TabController(length: 3, vsync: Scaffold.of(context));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: [
            TransactionsListView(
              controller: allTransactionsController,
              name: 'All Transactions',
              onLoaded: () => _currentController = allTransactionsController,
            ),
            TransactionsListView(
              controller: expansesTransactionsController,
              name: 'Expenses Transactions',
              type: TransactionType.expense,
              onLoaded: () =>
                  _currentController = expansesTransactionsController,
            ),
            TransactionsListView(
              controller: incomesTransactionsController,
              name: 'Incomes Transactions',
              type: TransactionType.income,
              onLoaded: () =>
                  _currentController = incomesTransactionsController,
            ),
          ],
        ),
        bottomNavigationBar: TransactionsBottomNavigationBar(
          tabController: _tabController!,
          foregroundColor: appBarForegroundColor(context)!,
          backgroundColor: theme.colorScheme.surface,
        ).getNavigationBar(context),
      ),
    );
  }

  @override
  FloatingActionButton? floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      key: const Key('addTransactionButton'),
      onPressed: () {
        // Navigate to the add transaction page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionsFormPage(
              backgroundColor: appBarBackgroundColor(context)!,
              foregroundColor: appBarForegroundColor(context)!,
              onClosed: refresh,
            ),
          ),
        );
      },
      shape: CircleBorder(),
      mini: true,
      backgroundColor: appBarBackgroundColor(context)!,
      foregroundColor: appBarForegroundColor(context)!,
      child: const Icon(Icons.add),
    );
  }

  void refresh() {
    _currentController?.refresh();
  }

  @override
  FloatingActionButtonLocation? floatingActionButtonLocation(
    BuildContext context,
  ) {
    return TransactionsFloatingActionButtonLocation(16.0, 64.0);
  }

  @override
  void dispose() {
    transactions.dispose();
    totalCount.dispose();
    pageSize.dispose();
    page.dispose();
    isError.dispose();
    refreshController?.dispose();
    _tabController?.dispose();

    super.dispose();
  }
}

class TransactionsFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  final double offsetX;
  final double offsetY;

  TransactionsFloatingActionButtonLocation(this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final scaffoldSize = scaffoldGeometry.scaffoldSize;
    final contentBottom = scaffoldSize.height - scaffoldGeometry.contentBottom;

    // Position the FAB at the bottom right with some offset
    return Offset(
      scaffoldSize.width - fabSize.width - offsetX,
      scaffoldSize.height - fabSize.height - contentBottom - offsetY,
    );
  }
}
