import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/models/requests/save_transaction.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:family_financial_app/models/responses/paginated.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api_accounts.dart';
import 'package:family_financial_app/plugins/api_category.dart';
import 'package:family_financial_app/plugins/api_transactions.dart';
import 'package:family_financial_app/plugins/size_util.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class TransactionsFormPage extends StatefulWidget {
  final String? itemId;
  final VoidCallback? onClosed;
  final Color backgroundColor;
  final Color foregroundColor;
  get isNew => itemId == null || itemId!.isEmpty;

  const TransactionsFormPage({
    this.itemId,
    this.onClosed,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
  });

  @override
  State<TransactionsFormPage> createState() => _TransactionsFormPageState();
}

class _TransactionsFormPageState extends State<TransactionsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _transactionTypes = Map<int, String>.from({
    -1: 'Expense',
    0: 'Transfer',
    1: 'Income',
  });

  String? _description = '';
  int _transactionType = -1; // -1 for expense, 1 for income, 0 for transfer
  String? _accountId;
  String? _categoryId;
  DateTime _date = DateTime.now();
  double _amount = 0.0;

  final _descriptionController = TextEditingController();

  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    if (widget.isNew) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTransactionData(context);
    });
  }

  Future<void> loadTransactionData(BuildContext context) async {
    final api = ApiTransactions(context);
    final messager = ScaffoldMessenger.of(context);
    final loaderOverlay = context.loaderOverlay;
    loaderOverlay.show();
    try {
      final response = await api.getTransactionById(
        transactionId: widget.itemId!,
      );

      if (response.hasError) {
        throw Exception('Failed to load transaction: ${response.message}');
      }

      setState(() {
        _description = response.data?.description ?? '';
        _transactionType = response.data?.transactionType ?? 0;
        _accountId = response.data?.account.id;
        _categoryId = response.data?.category.id;
        _date = response.data?.transactionDate ?? DateTime.now();
        _amount = response.data?.amount ?? 0.0;

        _descriptionController.text = _description!;
      });
    } catch (error) {
      messager.showSnackBar(
        SnackBar(
          content: Text('Error loading transaction: $error'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      loaderOverlay.hide();
    }
  }

  Future<List<dynamic>> loadFormData(BuildContext context) async {
    final categoryApi = ApiCategory(context);
    final accountsApi = ApiAccounts(context);
    final store = context.read<Store>();
    final user = store.user!.userId;

    final tasks = <Future>[];
    if (!widget.isNew && !_isLoaded) {
      tasks.add(loadTransactionData(context));
      _isLoaded = true;
    }
    tasks.addAll([
      categoryApi.getCategories(),
      accountsApi.getAccounts(userId: user),
    ]);
    return await Future.wait(tasks);
  }

  @override
  Widget build(BuildContext context) {
    final sizeUtil = SizeUtil(context);
    final messager = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Transaction' : 'Transaction Detail'),
      ),
      body: LoaderOverlay(
        child: Container(
          padding: sizeUtil.dynamicPadding(
            maxXPercentage: .1,
            maxYPercentage: .04,
          ),
          child: Column(
            children: <Widget>[
              FutureBuilder<List<dynamic>>(
                future: loadFormData(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final categories =
                      snapshot.data![0] as Res<Paginated<ItemCategory>>;
                  final accounts = snapshot.data![1] as Res<List<ItemAccount>>;

                  return Form(
                    key: _formKey,
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) => _description = value,
                        ),
                        DropdownButtonFormField<int>(
                          value: _transactionType,
                          items: _transactionTypes.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _transactionType = value ?? -1;
                          },
                          decoration: InputDecoration(
                            labelText: 'Transaction Type',
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _categoryId,
                          items:
                              categories.data?.items.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList() ??
                              [],
                          onChanged: (value) {
                            _categoryId = value;
                          },
                          decoration: InputDecoration(labelText: 'Category'),
                        ),
                        DropdownButtonFormField<String>(
                          value: _accountId,
                          items:
                              accounts.data?.map((account) {
                                return DropdownMenuItem<String>(
                                  value: account.id,
                                  child: Text(account.name),
                                );
                              }).toList() ??
                              [],
                          onChanged: (value) {
                            _accountId = value;
                          },
                          decoration: InputDecoration(labelText: 'Account'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ElevatedButton.icon(
                    key: const Key('saveCategoryButton'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: widget.foregroundColor,
                      backgroundColor: widget.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      final loaderOverlay = context.loaderOverlay;

                      if (!_formKey.currentState!.validate()) {
                        messager.showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: Colors.red.shade400,
                          ),
                        );
                      }

                      loaderOverlay.show();
                      save(context)
                          .then((_) {
                            messager.showSnackBar(
                              SnackBar(
                                content: Text('Category saved successfully!'),
                                backgroundColor: Colors.green.shade400,
                              ),
                            );

                            navigator.pop();
                            onClosed();
                          })
                          .catchError((error) {
                            messager.showSnackBar(
                              SnackBar(
                                content: Text('Error saving category: $error'),
                                backgroundColor: Colors.red.shade400,
                              ),
                            );
                          })
                          .whenComplete(() => loaderOverlay.hide());

                      return;
                    },
                    icon: const Icon(Icons.save),
                    label: Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> save(BuildContext context) async {
    final api = ApiTransactions(context);
    final payload = SaveTransaction(
      id: widget.itemId,
      description: _description,
      amount: _amount,
      transactionType: _transactionType,
      transactionDate: _date,
      categoryId: _categoryId,
      accountId: _accountId ?? '',
    );

    await api.saveTransaction(payload: payload);
  }

  void onClosed() {
    if (widget.onClosed == null) return;
    widget.onClosed!.call();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }
}
