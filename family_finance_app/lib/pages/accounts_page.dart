import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/bottom_menu.dart';
import 'package:family_financial_app/components/row_action.dart';
import 'package:family_financial_app/pages/accounts_detail_page.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountsPage extends MyPage {
  static const currentKey = 'AccountsPage';
  @override
  String get title => 'Accounts';
  final Api api;
  final Store store;
  final ScaffoldMessengerState messenger;

  final accounts = ValueNotifier<List<ItemAccount>>([]);
  final totalCount = ValueNotifier<int>(0);
  final pageSize = ValueNotifier<int>(10);
  final page = ValueNotifier<int>(1);
  final isLoading = ValueNotifier<bool>(false);
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

  AccountsPage(BuildContext context)
    : store = context.read<Store>(),
      api = Api(context),
      messenger = ScaffoldMessenger.of(context),
      super(route: 'AccountsPage', title: 'Accounts') {
    final navigator = Navigator.of(context);
    accounts.addListener(() {
      rows.clear();
      rows.addAll(
        accounts.value.map((account) {
          return DataRow(
            onLongPress: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return BottomMenu(
                  itemDetail: itemDetail(context, account),
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
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                    RowAction(
                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                      label: 'Delete',
                      onPressed: () {
                        showDeleteConfirmationDialog(context, account);
                      },
                    ),
                  ],
                ); // Placeholder for context menu
              },
            ),
            cells: [
              DataCell(Text(account.name)),
              DataCell(Text(account.description ?? '')),
              DataCell(
                Center(
                  child: Icon(
                    Icons.circle,
                    color: Utils.hexStringToColor(account.color),
                  ),
                ),
              ),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(account.balance.toString()),
                ),
              ),
              DataCell(Text(account.createdAt.toString())),
              DataCell(Text(account.updatedAt.toString())),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget itemDetail(BuildContext context, ItemAccount account) {
    return Column(
      children: [
        Center(child:
          Text(account.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Text(account.description ?? ''),
        Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 8), child:
          Text('Balance: ${account.balance}', style: TextStyle(fontSize: 16)),
        ),
        Text('Created: ${account.createdAt}'),
        Text('Updated: ${account.updatedAt}'),
      ],
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, ItemAccount account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final navigator = Navigator.of(context);
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete this account?\n${account.name}'),
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
                api.deleteAccount(
                  userId: store.getUser()?.userId ?? '',
                  accountId: account.id,
                ).then((response) {
                  if (response.success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Account deleted successfully'),
                        backgroundColor: Colors.green.shade400,
                      ),
                    );
                    navigator.pop(); // Close the dialog
                    loadTable(); // Refresh the table after deletion
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete account'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  }
                }).catchError((error) {
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
  Widget body() {
    return Center(
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns: columns,
              rows: rows,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onMounted() {
    // Perform any additional setup or state initialization here
    loadTable();
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
            builder: (context) => AccountsDetailPage(
              isNew: true,
              onClosed: () {
                loadTable();
              },
            ),
          ),
        );
      },
      shape: CircleBorder(),
      child: const Icon(Icons.add),
    );
  }

  /// Load the accounts table or any necessary data.
  void loadTable() {
    isLoading.value = true;
    final user = store.getUser();
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
          isLoading.value = false;
        });
  }

  @override
  void dispose() {
    accounts.dispose();
    totalCount.dispose();
    pageSize.dispose();
    page.dispose();
    isLoading.dispose();
    isError.dispose();
    super.dispose();
  }
}
