import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/api.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountsPage extends MyPage {
  static const currentKey = 'AccountsPage';
  static const String title = 'Accounts';
  final Api api;
  final Store store;
  final ScaffoldMessengerState messenger;

  final ValueNotifier<List<ItemAccount>> accounts = ValueNotifier<List<ItemAccount>>([]);
  final ValueNotifier<int> totalCount = ValueNotifier<int>(0);
  final ValueNotifier<int> pageSize = ValueNotifier<int>(10);
  final ValueNotifier<int> page = ValueNotifier<int>(1);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isError = ValueNotifier<bool>(false);


  AccountsPage(BuildContext context) 
  : store = context.read<Store>(),
  api = Api(context),
  messenger = ScaffoldMessenger.of(context),
  super(appBar: AppBar(title: Text(title)));

  @override
  Widget body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('This is the Accounts page.'),
        ],
      ),
    );
  }

  @override
  void onMounted() {
    // Perform any additional setup or state initialization here
    loadTable();
  }

  /// Load the accounts table or any necessary data.
  void loadTable() {
    isLoading.value = true;
    final user = store.getUser();
    if (user == null) throw Exception('User not logged in');
    api.getAccounts(userId: user.userId, page: page.value, pageSize: pageSize.value).then((response) {
      if (response.success) {
        accounts.value = response.data?.items ?? [];
        totalCount.value = response.data?.totalCount ?? 0;
      } else {
        isError.value = true;
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to load accounts')),
        );
      }
    }).catchError((error) {
      isError.value = true;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to load accounts')),
      );
    }).whenComplete(() {
      isLoading.value = false;
    });
  }
}
