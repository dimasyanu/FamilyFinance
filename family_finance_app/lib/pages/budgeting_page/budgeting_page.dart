import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/bottom_action_menu.dart';
import 'package:family_financial_app/components/row_action.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_budget.dart';
import 'package:family_financial_app/pages/budgeting_page/budgeting_detail.dart';
import 'package:family_financial_app/pages/budgeting_page/budgeting_form_page.dart';
import 'package:family_financial_app/pages/budgeting_page/budgeting_table_source.dart';
import 'package:family_financial_app/plugins/api_budgeting.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    hide RefreshIndicatorState;

class BudgetingPage extends MyPage {
  final ApiBudgeting api;
  final Store store;
  final ScaffoldMessengerState messenger;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  final budgets = ValueNotifier<List<ItemBudget>>([]);
  final totalCount = ValueNotifier<int>(0);
  final pageSize = ValueNotifier<int>(10);
  final page = ValueNotifier<int>(1);
  final isError = ValueNotifier<bool>(false);
  final refreshController = RefreshController(initialRefresh: false);

  static const headerStyle = TextStyle(fontWeight: FontWeight.bold);

  final List<DataColumn> columns = const [
    DataColumn(
      label: Row(
        children: [
          SizedBox(width: 16.0),
          Text('Period', style: headerStyle),
        ],
      ),
    ),
    DataColumn(label: Text('Category', style: headerStyle)),
    DataColumn(label: Text('Created At', style: headerStyle)),
    DataColumn(label: Text('Created by', style: headerStyle)),
  ];

  BudgetingPage(super.context)
    : store = context.read<Store>(),
      messenger = ScaffoldMessenger.of(context),
      api = ApiBudgeting(context),
      super(route: 'BudgetingPage', title: 'Budgeting');

  @override
  Color? appBarForegroundColor() {
    return Colors.white;
  }

  @override
  Color? appBarBackgroundColor() {
    return Colors.cyan;
  }

  @override
  Widget? appBarTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      key: const Key('appBarTitle'),
      children: [
        Icon(Icons.attach_money, color: appBarForegroundColor()),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: TextStyle(color: appBarForegroundColor(), fontSize: 18),
        ),
      ],
    );
  }

  @override
  Widget body(BuildContext context) {
    // loadTable(context);
    _refreshKey.currentState?.show();
    final navigator = Navigator.of(context);
    return SmartRefresher(
      key: _refreshKey,
      controller: refreshController,
      enablePullDown: true,
      header: WaterDropMaterialHeader(
        backgroundColor: appBarBackgroundColor(),
        color: Colors.white,
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
            source: BudgetingTableSource(
              context: context,
              budgets: budgets.value,
              onRowLongPressed: (budget) => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BottomActionMenu(
                    itemDetail: BudgetingDetail(budget: budget),
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
                              builder: (context) => BudgetingFormPage(
                                itemId: budget.id,
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
                          showDeleteConfirmationDialog(context, budget);
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

  @override
  void onMounted(BuildContext context) {
    loadTable(context).then((_) {
      refreshController.refreshCompleted();
    });
  }

  /// Load the budgeting table or any necessary data.
  Future<void> loadTable(BuildContext context) async {
    final user = store.getUser();
    final loaderOverlay = context.loaderOverlay;
    loaderOverlay.show();
    if (user == null) throw Exception('User not logged in');
    try {
      final response = await api.getBudgets(
        page: page.value,
        pageSize: pageSize.value,
      );
      debugPrint(response.success.toString());
      if (response.success) {
        setState(() {
          isError.value = false;
          budgets.value = response.data?.items ?? [];
          totalCount.value = response.data?.totalCount ?? 0;
        });
      } else {
        isError.value = true;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to load budgets'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      isError.value = true;
      debugPrint('Error loading budgets: $error');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to load budgets'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
    loaderOverlay.hide();
  }

  Future<void> deleteItem(
    String userId,
    String budgetId,
    OverlayExtensionHelper loaderOverlay,
    ScaffoldMessengerState messenger,
    NavigatorState navigator,
    VoidCallback loadTable,
  ) async {
    loaderOverlay.show();
    try {
      final response = await api.deleteBudget(budgetId: budgetId);
      if (response.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Budget deleted successfully'),
            backgroundColor: Colors.green.shade400,
          ),
        );
        navigator.pop(); // Close the dialog
        () => loadTable(); // Refresh the table after deletion
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete budget'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete budget'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      loaderOverlay.hide();
      loadTable();
      navigator.pop();
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, ItemBudget budget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final navigator = Navigator.of(context);
        final loaderOverlay = context.loaderOverlay;
        return AlertDialog(
          title: Text('Delete Budget'),
          content: Text(
            'Are you sure you want to delete this budget?\n${Utils.getMonthName(budget.month)} ${budget.year} - ${budget.category.name}',
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
                await deleteItem(
                  store.getUser()?.userId ?? '',
                  budget.id,
                  loaderOverlay,
                  messenger,
                  navigator,
                  () => refreshController.requestRefresh(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  FloatingActionButton? floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      key: const Key('addBudgetButton'),
      onPressed: () {
        // Navigate to the add budget page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetingFormPage(
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
      backgroundColor: appBarBackgroundColor(),
      foregroundColor: appBarForegroundColor(),
      child: const Icon(Icons.add),
    );
  }

  @override
  void dispose() {
    budgets.dispose();
    refreshController.dispose();
    totalCount.dispose();
    pageSize.dispose();
    page.dispose();
    isError.dispose();
    super.dispose();
  }
}
