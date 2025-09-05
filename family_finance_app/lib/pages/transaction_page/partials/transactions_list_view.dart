import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/bottom_action_menu.dart';
import 'package:family_financial_app/components/row_action.dart';
import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/pages/transaction_page/partials/transactions_list_item.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_detail.dart';
import 'package:family_financial_app/pages/transaction_page/transactions_form_page.dart';
import 'package:family_financial_app/plugins/api_transactions.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
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
      child: Builder(
        builder: (context) {
          if (_transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No transactions available.',
                  style: GoogleFonts.interTight(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_transactions.length, (index) {
                var item = _transactions[index];
                return TransactionsListItem(
                  transaction: item,
                  onTap: () => showDetail(item),
                  onLongPress: () => showActions(context, item),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  void loadItems() {
    final api = ApiTransactions(context);
    final messager = ScaffoldMessenger.of(context);
    api
        .getTransactions(type: widget.type)
        .then((response) {
          setState(() {
            _transactions.clear();
            _transactions.addAll(response.data?.items ?? []);
            debugPrint('Loaded ${_transactions.length} transactions');
          });
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

  void showDetail(ItemTransaction transaction) {
    // Show modal with transaction details
    showDialog(
      context: context,
      builder: (context) {
        final cellPadding = EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: 4.0,
        );
        final headerStyle = GoogleFonts.interTight(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        );
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            transaction.description,
            style: GoogleFonts.interTight(),
            textAlign: TextAlign.center,
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            width: double.maxFinite,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                2: FlexColumnWidth(),
              },
              children: <TableRow>[
                TableRow(
                  children: [
                    Text('Amount', style: headerStyle),
                    Padding(padding: cellPadding, child: Text(':')),
                    Text(
                      (transaction.transactionType == TransactionType.income
                              ? ''
                              : '- ') +
                          Utils.formatCurrency(transaction.amount),
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        color:
                            transaction.transactionType ==
                                TransactionType.income
                            ? Colors.green.shade700
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Date', style: headerStyle),
                    Padding(padding: cellPadding, child: Text(':')),
                    Text(
                      transaction.transactionDate,
                      style: GoogleFonts.interTight(),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Time:', style: headerStyle),
                    Padding(padding: cellPadding, child: Text(':')),
                    Text(
                      transaction.transactionTime,
                      style: GoogleFonts.interTight(),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Account', style: headerStyle),
                    Padding(padding: cellPadding, child: Text(':')),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Utils.hexStringToColor(
                            transaction.accountColor,
                          ),
                          size: 14,
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          transaction.account,
                          style: GoogleFonts.interTight(),
                        ),
                      ],
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Category', style: headerStyle),
                    Padding(padding: cellPadding, child: Text(':')),
                    Row(
                      children: [
                        Icon(
                          IconData(
                            transaction.categoryIcon,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: Utils.hexStringToColor(
                            transaction.categoryColor,
                          ),
                          size: 14,
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          transaction.category,
                          style: GoogleFonts.interTight(),
                        ),
                      ],
                    ),
                  ],
                ),
                if (transaction.notes != null) ...[
                  TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Text('Notes', style: headerStyle),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(':'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Text(
                          transaction.notes!,
                          style: GoogleFonts.interTight(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showActions(BuildContext context, ItemTransaction transaction) {
    final navigator = Navigator.of(context);
    showModalBottomSheet(
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
                      foregroundColor: Colors.blue.shade700,
                      backgroundColor: Colors.white,
                      itemId: transaction.id,
                      onClosed: () {
                        refreshController.requestRefresh();
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
                showDeleteConfirmationDialog(context, transaction);
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(
    BuildContext context,
    ItemTransaction transaction,
  ) {
    final store = context.read<Store>();
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final navigator = Navigator.of(context);
        return LoaderOverlay(
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: Text('Delete Transaction'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Text(
                    'Are you sure you want to delete this transaction?\n${transaction.description}',
                  ),
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

  Future<void> deleteItem(
    String userId,
    String accountId,
    ScaffoldMessengerState messenger,
    NavigatorState navigator,
    VoidCallback loadTable,
  ) async {
    final api = ApiTransactions(context);
    refreshController.requestLoading();
    try {
      final response = await api.deleteTransaction(transactionId: accountId);
      if (response.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green.shade400,
          ),
        );
        navigator.pop(); // Close the dialog
        () => loadTable(); // Refresh the table after deletion
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete transaction'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      refreshController.refreshCompleted();
      loadTable();
      navigator.pop();
    }
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
