import 'package:family_financial_app/abstractions/store.dart';
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

  final ValueNotifier<List<ItemAccount>> accounts =
      ValueNotifier<List<ItemAccount>>([]);
  final ValueNotifier<int> totalCount = ValueNotifier<int>(0);
  final ValueNotifier<int> pageSize = ValueNotifier<int>(10);
  final ValueNotifier<int> page = ValueNotifier<int>(1);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isError = ValueNotifier<bool>(false);

  final List<DataColumn> columns = const [
    DataColumn(
      label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    DataColumn(
      label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    DataColumn(
      label: Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    DataColumn(
      label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)),
      headingRowAlignment: MainAxisAlignment.end
    ),
    DataColumn(
      label: Text('Created At', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    DataColumn(
      label: Text('Updated At', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    DataColumn(
      label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
      headingRowAlignment: MainAxisAlignment.center,
    ),
  ];

  List<DataRow> rows = [];

  AccountsPage(BuildContext context)
    : store = context.read<Store>(),
      api = Api(context),
      messenger = ScaffoldMessenger.of(context),
      super(route: 'AccountsPage', title: 'Accounts') {
    accounts.addListener(() {
      rows.clear();
      rows.addAll(
        accounts.value.map((account) {
          return DataRow(
            cells: [
              DataCell(Text(account.name)),
              DataCell(Text(account.description ?? '')),
              DataCell(Container(color: Utils.hexStringToColor(account.color))),
              DataCell(Align(alignment: Alignment.centerRight,child: Text(account.balance.toString()),)),
              DataCell(Text(account.createdAt.toString())),
              DataCell(Text(account.updatedAt.toString())),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Handle delete action
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      );
    });
  }

  @override
  Widget body() {
    return Center(
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(columns: columns, rows: rows),
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
            builder: (context) => AccountsDetailPage(isNew: true),
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
