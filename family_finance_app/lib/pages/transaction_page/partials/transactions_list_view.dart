import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_list_item.dart';
import 'package:family_financial_app/plugins/api_transactions.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class TransactionsListView extends StatefulWidget {
  final TransactionsListViewController controller;
  final String? name;

  const TransactionsListView({super.key, required this.controller, this.name});

  @override
  State<TransactionsListView> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  final List<ItemTransaction> _transactions = [];
  final refreshController = RefreshController();
  // final ValueNotifier<bool> _isActive = ValueNotifier(false);
  bool _isActive = false;

  _TransactionsListViewState() {
    // widget.controller.setInvoker((context) {
    // setState(() {
    // _isActive = true;
    // });
    // });
    // widget.controller.setDestroyer(destroy);
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing TransactionsListView');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) {
      return Center(child: Text('No transactions found.'));
    }

    return SmartRefresher(
      controller: refreshController,
      onRefresh: () {
        _transactions.clear();
        loadItems();
      },
      child: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return TransactionsListItem(transaction: transaction);
        },
      ),
    );
  }

  void loadItems() {
    final api = ApiTransactions(context);
    final messager = ScaffoldMessenger.of(context);
    api
        .getTransactions()
        .then((response) {
          _transactions.addAll(response.data?.items ?? []);

          for (int i = 0; i < 10; i++) {
            _transactions.add(
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
          debugPrint('Loaded ${_transactions.length} transactions');
        })
        .catchError((error) {
          debugPrint('Error loading transactions: $error');
          messager.showSnackBar(
            SnackBar(content: Text('Failed to load transactions: $error')),
          );
        })
        .whenComplete(() {
          refreshController.refreshCompleted();
        });
  }

  void invoker(BuildContext context) {
    // debugPrint('Loading: $name');
  }

  void destroy() {
    debugPrint('Destroying: ${widget.name}');
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }
}

class TransactionsListViewController {
  late final Function(BuildContext context) invoke;
  late final Function destroy;

  TransactionsListViewController();

  void setInvoker(Function(BuildContext context) invoker) {
    invoke = invoker;
  }

  void setDestroyer(Function destroyer) {
    destroy = destroyer;
  }

  void loadView(BuildContext context) {
    invoke(context);
  }

  void destroyView() {
    destroy();
  }
}
