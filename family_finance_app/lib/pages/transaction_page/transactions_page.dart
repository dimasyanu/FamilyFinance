import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/bottom_action_menu.dart';
import 'package:family_financial_app/components/row_action.dart';
import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_bottom_navigation_bar.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_list_view.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_detail.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_form_page.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_table_source.dart';
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
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

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
    allTransactionsController.loadView(context);
  }

  @override
  Widget build(BuildContext context) {
    initTabs(context);
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
            ), // Placeholder for categories
            TransactionsListView(
              controller: incomesTransactionsController,
              name: 'Incomes Transactions',
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
    _tabController = TabController(length: 3, vsync: Scaffold.of(context));
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

  Widget build1(BuildContext context) {
    _refreshKey.currentState?.show();
    final navigator = Navigator.of(context);
    return SmartRefresher(
      key: _refreshKey,
      controller: refreshController,
      enablePullDown: true,
      header: WaterDropMaterialHeader(
        backgroundColor: appBarBackgroundColor(),
        color: appBarForegroundColor()!,
        distance: 80.0,
      ),
      onRefresh: () async {
        await loadTable(context);
        refreshController.refreshCompleted();
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: PaginatedDataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
            columns: columns,
            showEmptyRows: false,
            source: TransactionsTableSource(
              context: context,
              transactions: transactions.value,
              onRowLongPressed: (transaction) => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BottomActionMenu(
                    itemDetail: TransactionsDetail(transaction: transaction),
                    actions: [
                      RowAction(
                        icon: Icon(Icons.close, color: Colors.grey),
                        label: 'Cancel',
                        onPressed: () {
                          navigator.pop(); // Close the bottom sheet
                        },
                      ),
                      RowAction(
                        icon: Icon(Icons.edit),
                        label: 'Edit',
                        backgroundColor: Colors.blue.shade50,
                        onPressed: () {
                          navigator.pop();
                          navigator.push(
                            MaterialPageRoute(
                              builder: (context) => TransactionsFormPage(
                                itemId: transaction.id,
                                onClosed: () {
                                  refreshController.requestRefresh();
                                },
                                backgroundColor: appBarBackgroundColor()!,
                                foregroundColor: appBarForegroundColor()!,
                              ),
                            ),
                          );
                        },
                      ),
                      RowAction(
                        icon: Icon(Icons.delete, color: Colors.red.shade300),
                        label: 'Delete',
                        backgroundColor: Colors.red.shade50,
                        onPressed: () {
                          showDeleteConfirmationDialog(context, transaction);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Load the categories table or any necessary data.
  Future<void> loadTable(BuildContext context) async {
    final user = store.getUser();
    if (user == null) throw Exception('User not logged in');
    try {
      final response = await api.getTransactions(
        page: page.value,
        pageSize: pageSize.value,
      );
      if (response.success) {
        setState(() {
          isError.value = false;
          // transactions.value = response.data?.items ?? [];
          totalCount.value = response.data?.totalCount ?? 0;
          for (int i = 0; i < 10; i++) {
            transactions.value.add(
              ItemTransaction(
                id: 'txn_$i',
                account: 'Account $i',
                transactionDate: DateTime.now()
                    .subtract(Duration(days: i))
                    .toString(),
                transactionType: i % 2 == 0
                    ? TransactionType.income
                    : TransactionType.expense,
                description: 'Transaction $i',
                amount: 50.0 * (i + 1),
                category: 'Category $i',
              ),
            );
          }
        });
      } else {
        isError.value = true;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to load categories'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      isError.value = true;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to load categories'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
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
      key: const Key('addCategoryButton'),
      onPressed: () {
        // Navigate to the add category page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionsFormPage(
              backgroundColor: appBarBackgroundColor()!,
              foregroundColor: appBarForegroundColor()!,
              onClosed: () {
                refreshController.requestRefresh();
              },
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

  @override
  void dispose() {
    transactions.dispose();
    totalCount.dispose();
    pageSize.dispose();
    page.dispose();
    isError.dispose();
    refreshController.dispose();
    _tabController?.dispose();
    // _tabController.dispose();
    super.dispose();
  }
}
