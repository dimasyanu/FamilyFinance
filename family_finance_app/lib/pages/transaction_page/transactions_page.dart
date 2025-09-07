import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_bottom_navigation_bar.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_list_view.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_form_page.dart';
import 'package:family_financial_app/plugins/api_transactions.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
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
  final refreshController = RefreshController(initialRefresh: false);
  int _currentTabIndex = 0;

  final allTransactionsController = TransactionsListViewController();
  final expansesTransactionsController = TransactionsListViewController();
  final incomesTransactionsController = TransactionsListViewController();

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
  Color? appBarForegroundColor() {
    return Colors.blue.shade700;
  }

  @override
  Color? appBarBackgroundColor() {
    return Colors.white;
  }

  @override
  Widget? appBarTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      key: const Key('appBarTitle'),
      children: [
        Icon(Icons.category, color: appBarForegroundColor()),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: TextStyle(color: appBarForegroundColor(), fontSize: 18),
        ),
      ],
    );
  }

  @override
  Future<void> onMounted(BuildContext context) async {
    // allTransactionsController.invoke(context);
    // initTabs(context);
  }

  @override
  Widget build(BuildContext context) {
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
            ), // Placeholder for categories
            TransactionsListView(
              controller: expansesTransactionsController,
              name: 'Expenses Transactions',
              type: TransactionType.expense,
            ), // Placeholder for categories
            TransactionsListView(
              controller: incomesTransactionsController,
              name: 'Incomes Transactions',
              type: TransactionType.income,
            ), // Placeholder for accounts
          ],
        ),
        bottomNavigationBar: TransactionsBottomNavigationBar(
          tabController: _tabController!,
          foregroundColor: appBarForegroundColor()!,
        ).getNavigationBar(context),
      ),
    );
  }

  void initTabs(BuildContext context) {
    final controllers = [
      allTransactionsController,
      expansesTransactionsController,
      incomesTransactionsController,
    ];

    _tabController?.addListener(() {
      if (_tabController!.index == _currentTabIndex) return;
      _currentTabIndex = _tabController!.index;
      final previousTabIndex = _tabController!.previousIndex;

      controllers[_currentTabIndex].loadView(context);
      controllers[previousTabIndex].destroy();
    });
  }

  Future<void> deleteItem(
    String userId,
    String transactionId,
    ScaffoldMessengerState messenger,
    NavigatorState navigator,
    VoidCallback loadTable,
  ) async {
    refreshController.requestLoading();
    try {
      final response = await api.deleteTransaction(
        transactionId: transactionId,
      );
      if (response.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green.shade400,
          ),
        );
        navigator.pop(); // Close the dialog
        () => loadTable(); // Refresh the table after deletion
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete category'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete category'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      refreshController.refreshCompleted();
      loadTable();
      navigator.pop();
    }
  }

  void showDeleteConfirmationDialog(
    BuildContext context,
    ItemTransaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final navigator = Navigator.of(context);
        return LoaderOverlay(
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: Text('Delete Transaction'),
                content: Text(
                  'Are you sure you want to delete this transaction?\n${transaction.description}',
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      navigator.pop();
                    },
                  ),
                  TextButton(
                    child: Text('Delete'),
                    onPressed: () async {
                      final loaderOverlay = context.loaderOverlay;
                      loaderOverlay.show();

                      await deleteItem(
                        store.getUser()?.userId ?? '',
                        transaction.id,
                        messenger,
                        navigator,
                        () {
                          loaderOverlay.hide();
                          refreshController.requestRefresh();
                        },
                      );
                      loaderOverlay.hide();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
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
              backgroundColor: appBarBackgroundColor()!,
              foregroundColor: appBarForegroundColor()!,
              onClosed: refresh,
            ),
          ),
        );
      },
      shape: CircleBorder(),
      mini: true,
      backgroundColor: appBarBackgroundColor(),
      foregroundColor: appBarForegroundColor(),
      child: const Icon(Icons.add),
    );
  }

  void refresh() {
    refreshController.requestRefresh();
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
    refreshController.dispose();
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
