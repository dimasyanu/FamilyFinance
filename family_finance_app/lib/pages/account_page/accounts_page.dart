import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/bottom_action_menu.dart';
import 'package:family_financial_app/components/row_action.dart';
import 'package:family_financial_app/pages/account_page/accounts_detail.dart';
import 'package:family_financial_app/pages/account_page/accounts_table_source.dart';
import 'package:family_financial_app/pages/account_page/accounts_form_page.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class AccountsPage extends MyPage {
  static const currentKey = 'AccountsPage';
  @override
  String get title => 'Accounts';
  final Api api;
  final Store store;
  final ScaffoldMessengerState messenger;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  final accounts = ValueNotifier<List<ItemAccount>>([]);
  final totalCount = ValueNotifier<int>(0);
  final pageSize = ValueNotifier<int>(10);
  final page = ValueNotifier<int>(1);
  final isError = ValueNotifier<bool>(false);

  static const headerStyle = TextStyle(fontWeight: FontWeight.bold);

  final List<DataColumn> columns = const [
    DataColumn(label: Text('Name', style: headerStyle)),
    DataColumn(label: Text('Description', style: headerStyle)),
    DataColumn(label: Text('Color', style: headerStyle)),
    DataColumn(
      label: Text('Balance', style: headerStyle),
      headingRowAlignment: MainAxisAlignment.end,
    ),
    DataColumn(label: Text('Created At', style: headerStyle)),
    DataColumn(label: Text('Updated At', style: headerStyle)),
  ];

  final List<DataRow> rows = [];

  AccountsPage(super.context)
    : store = context.read<Store>(),
      api = Api(context),
      messenger = ScaffoldMessenger.of(context),
      super(route: 'AccountsPage', title: 'Accounts');

  @override
  Widget body(BuildContext context) {
    // loadTable(context);
    _refreshKey.currentState?.show();
    final navigator = Navigator.of(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async {
          loadTable(context);
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                          Navigator.push(
                            context,
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

  @override
  void onMounted(BuildContext context) {
    // Perform any additional setup or state initialization here
    loadTable(context);
  }

  /// Load the accounts table or any necessary data.
  void loadTable(BuildContext context) {
    final user = store.getUser();
    final loaderOverlay = context.loaderOverlay;
    loaderOverlay.show();
    if (user == null) throw Exception('User not logged in');
    api
        .getAccounts(
          userId: user.userId,
          page: page.value,
          pageSize: pageSize.value,
        )
        .then((response) {
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
        })
        .catchError((error) {
          isError.value = true;
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to load accounts'),
              backgroundColor: Colors.red.shade400,
            ),
          );
        })
        .whenComplete(() {
          loaderOverlay.hide();
        });
  }

  void showDeleteConfirmationDialog(BuildContext context, ItemAccount account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final navigator = Navigator.of(context);
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
              onPressed: () {
                api
                    .deleteAccount(
                      userId: store.getUser()?.userId ?? '',
                      accountId: account.id,
                    )
                    .then((response) {
                      if (response.success) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Account deleted successfully'),
                            backgroundColor: Colors.green.shade400,
                          ),
                        );
                        navigator.pop(); // Close the dialog
                        () => loadTable(
                          context,
                        ); // Refresh the table after deletion
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete account'),
                            backgroundColor: Colors.red.shade400,
                          ),
                        );
                      }
                    })
                    .catchError((error) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete account'),
                          backgroundColor: Colors.red.shade400,
                        ),
                      );
                    });
                navigator.pop();
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
                loadTable(context);
              },
            ),
          ),
        );
      },
      shape: CircleBorder(),
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
