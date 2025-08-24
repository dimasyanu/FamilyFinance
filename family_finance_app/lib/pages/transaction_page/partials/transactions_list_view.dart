import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_list_item.dart';
import 'package:family_financial_app/plugins/api_transactions.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class TransactionsListView extends StatefulWidget {
  final TransactionsListViewController controller;
  final String? name;
  final int? type;
  final String backgroundColor = '#f6f8fa';

  const TransactionsListView({
    super.key,
    required this.controller,
    this.name,
    this.type,
  });

  @override
  State<TransactionsListView> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  final List<ItemTransaction> _transactions = [];
  final refreshController = RefreshController();

  _TransactionsListViewState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshController.requestRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      onRefresh: () {
        loadItems();
      },
      header: const WaterDropMaterialHeader(
        backgroundColor: Colors.white,
        color: Colors.blue,
        distance: 80.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(_transactions.length, (index) {
            return TransactionsListItem(transaction: _transactions[index]);
          }),
        ),
      ),
    );
  }

  void loadItems() {
    final api = ApiTransactions(context);
    final messager = ScaffoldMessenger.of(context);
    api
        .getTransactions(type: widget.type)
        .then((response) {
          _transactions.clear();
          _transactions.addAll(response.data?.items ?? []);

          final tmp = <ItemTransaction>[];
          for (int i = 0; i < 30; i++) {
            final now = DateTime.now().subtract(Duration(days: i));
            tmp.add(
              ItemTransaction(
                id: 'txn_$i',
                account: 'Account $i',
                accountColor:
                    '#${(0x1000000 + (i * 0xFFFFFF / 30).toInt()).toRadixString(16).substring(1)}',
                transactionDate:
                    '${now.day.toString()} ${Utils.getMonthName(now.month - 1)} ${now.year}',
                transactionTime:
                    '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                transactionType: i % 2 == 0
                    ? TransactionType.income
                    : TransactionType.expense,
                description: 'Transaction $i',
                amount: 500000000.0 / (i + 1),
                categoryIcon: 984964 + i,
                categoryColor:
                    '#${(0x1000000 + (i * 0xFFFFFF / 30).toInt()).toRadixString(16).substring(1)}',
                category: 'Category $i',
                notes: i % 3 == 0
                    ? 'Lorem Ipsum dolor sir amet, note for transaction $i'
                    : null,
              ),
            );
          }
          setState(() {
            _transactions.addAll(tmp);
          });
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
