import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_list_item.dart';
import 'package:flutter/material.dart';

class TransactionsListView extends StatelessWidget {
  final TransactionsListViewController controller;
  final String? name;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  TransactionsListView({super.key, required this.controller, this.name}) {
    controller.setInvoker(invoker);
    controller.setDestroyer(destroy);
  }

  void invoker() {
    debugPrint('Loading: $name');
  }

  void destroy() {
    debugPrint('Destroying: $name');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading.value) {
      return Center(child: Text('No transactions found.'));
    }

    return ListView.builder(
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return TransactionsListItem(transaction: transaction);
      },
    );
  }
}

class TransactionsListViewController {
  final List<ItemTransaction> transactions;
  late final Function invoke;
  late final Function destroy;

  TransactionsListViewController() : transactions = [];

  void setInvoker(Function invoker) {
    invoke = invoker;
  }

  void setDestroyer(Function destroyer) {
    destroy = destroyer;
  }

  void loadView(BuildContext context) {
    invoke();
  }

  void destroyView() {
    transactions.clear();
    destroy();
  }
}
