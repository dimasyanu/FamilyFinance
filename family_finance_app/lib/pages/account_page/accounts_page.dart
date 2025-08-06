import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/bottom_action_menu.dart';
import 'package:family_financial_app/components/row_action.dart';
import 'package:family_financial_app/pages/account_page/accounts_detail.dart';
import 'package:family_financial_app/pages/account_page/accounts_table_source.dart';
import 'package:family_financial_app/pages/account_page/accounts_form_page.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/plugins/api_accounts.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    hide RefreshIndicatorState;

class AccountsPage extends MyPage {
  static const currentKey = 'AccountsPage';
  @override
  String get title => 'Accounts';
  final ApiAccounts api;
  final Store store;
  final ScaffoldMessengerState messenger;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  final accounts = ValueNotifier<List<ItemAccount>>([]);
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
          Text('Name', style: headerStyle),
        ],
      ),
    ),
    DataColumn(label: Text('Description', style: headerStyle)),
    DataColumn(
      label: Text('Balance', style: headerStyle),
      headingRowAlignment: MainAxisAlignment.end,
    ),
    DataColumn(label: Text('Created At', style: headerStyle)),
    DataColumn(label: Text('Updated At', style: headerStyle)),
  ];

  final List<DataRow> rows = [];

  // Constructor
  AccountsPage(super.context)
    : store = context.read<Store>(),
      messenger = ScaffoldMessenger.of(context),
      api = ApiAccounts(context),
      super(route: 'AccountsPage', title: 'Accounts');

  @override
  Color? appBarForegroundColor() {
    return Colors.white;
  }

  @override
  Color? appBarBackgroundColor() {
    return Colors.blue;
  }

  @override
  Widget? appBarTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      key: const Key('appBarTitle'),
      children: [
        Icon(Icons.account_balance_wallet, color: appBarForegroundColor()),
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
    await refreshController.requestRefresh();
  }

  @override
  Widget build(BuildContext context) {
    _refreshKey.currentState?.show();
    final navigator = Navigator.of(context);
    return SmartRefresher(
      key: _refreshKey,
      controller: refreshController,
      enablePullDown: true,
      header: const WaterDropMaterialHeader(
        backgroundColor: Colors.blue,
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
            source: AccountsTableSource(
              context: context,
              accounts: accounts.value,
              loadTable: () => loadTable(context),
              onRowLongPressed: (account) => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BottomActionMenu(
                    itemDetail: AccountDetail(account: account),
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
                              builder: (context) => AccountsFormPage(
                                itemId: account.id,
                                onClosed: () {
                                  loadTable(context);
                                },
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
                          showDeleteConfirmationDialog(context, account);
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

  /// Load the accounts table or any necessary data.
  Future<void> loadTable(BuildContext context) async {
    final user = store.getUser();
    if (user == null) throw Exception('User not logged in');
    try {
      final response = await api.getAccounts(
        userId: user.userId,
        page: page.value,
        pageSize: pageSize.value,
      );
      if (response.success) {
        setState(() {
          isError.value = false;
          accounts.value = response.data?.items ?? [];
          totalCount.value = response.data?.totalCount ?? 0;
        });
      } else {
        isError.value = true;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to load accounts'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      isError.value = true;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to load accounts'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> deleteItem(
    String userId,
    String accountId,
    OverlayExtensionHelper loaderOverlay,
    ScaffoldMessengerState messenger,
    NavigatorState navigator,
    VoidCallback loadTable,
  ) async {
    refreshController.requestLoading();
    try {
      final response = await api.deleteAccount(
        userId: store.getUser()?.userId ?? '',
        accountId: accountId,
      );
      if (response.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green.shade400,
          ),
        );
        navigator.pop(); // Close the dialog
        () => loadTable(); // Refresh the table after deletion
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete account'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete account'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      refreshController.refreshCompleted();
      loadTable();
      navigator.pop();
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, ItemAccount account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final navigator = Navigator.of(context);
        final loaderOverlay = context.loaderOverlay;
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
            'Are you sure you want to delete this account?\n${account.name}',
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
                  account.id,
                  loaderOverlay,
                  messenger,
                  navigator,
                  () => loadTable(context),
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
      key: const Key('addAccountButton'),
      onPressed: () {
        // Navigate to the add account page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountsFormPage(
              onClosed: () {
                refreshController.requestRefresh();
              },
            ),
          ),
        );
      },
      shape: CircleBorder(),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  @override
  void dispose() {
    accounts.dispose();
    totalCount.dispose();
    pageSize.dispose();
    page.dispose();
    isError.dispose();
    super.dispose();
  }
}
