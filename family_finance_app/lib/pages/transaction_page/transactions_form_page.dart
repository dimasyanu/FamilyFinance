import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/transaction_type.dart';
import 'package:family_financial_app/models/requests/save_transaction.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:family_financial_app/models/responses/paginated.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api_accounts.dart';
import 'package:family_financial_app/plugins/api_category.dart';
import 'package:family_financial_app/plugins/api_transactions.dart';
import 'package:family_financial_app/plugins/size_util.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _amountInputFormatter = CurrencyTextInputFormatter.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );
  final _transactionTypes = Map<int, String>.from({
    -1: 'Expense',
    1: 'Income',
    0: 'Transfer',
  });

  String? _description = '';
  int _transactionType = -1; // -1 for expense, 1 for income, 0 for transfer
  String? _accountId;
  String? _toAccountId;
  String? _categoryId;
  DateTime _date = DateTime.now();
  DateTime _time = DateTime.now();
  double _amount = 0.0;
  List<ItemAccount> _accounts = [];
  List<ItemCategory> _categories = [];

  final _descriptionController = TextEditingController();

  bool _isLoadingTransaction = false;
  bool _isLoadingFormData = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isLoadingFormData = true);
      loadFormData(context);
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
      setState(() {
        _isLoadingTransaction = false;
      });
    }
  }

  Future<void> loadFormData(BuildContext context) async {
    final categoryApi = ApiCategory(context);
    final accountsApi = ApiAccounts(context);
    final store = context.read<Store>();
    final user = store.user!.userId;

    final tasks = <Future>[];
    if (!widget.isNew) {
      tasks.add(loadTransactionData(context));
    }
    tasks.addAll([
      categoryApi.getCategories(),
      accountsApi.getAccounts(userId: user),
    ]);
    final results = await Future.wait(tasks);
    setState(() {
      _isLoadingFormData = false;
      _isLoadingTransaction = false;
      if (results.length > 1) {
        final categories = results[0] as Res<Paginated<ItemCategory>>;
        final accounts = results[1] as Res<Paginated<ItemAccount>>;
        _categories = categories.data?.items ?? [];
        _accounts = accounts.data?.items ?? [];
      }
    });
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
              Builder(
                builder: (context) {
                  if (_isLoadingTransaction || _isLoadingFormData) {
                    return Center(child: CircularProgressIndicator());
                  }

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
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a description'
                              : null,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: DropdownButtonFormField<int>(
                                value: _transactionType,
                                items: _transactionTypes.entries.map((entry) {
                                  return DropdownMenuItem<int>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _transactionType = value ?? -1;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Transaction Type',
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Flexible(
                              child: TextField(
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  prefixText: 'Rp ',
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  _amountInputFormatter,
                                ],
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            if (_transactionType == TransactionType.transfer) {
                              return SizedBox.shrink();
                            }

                            return DropdownButtonFormField<String>(
                              value: _categoryId,
                              items: _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        IconData(
                                          category.icon,
                                          fontFamily: 'MaterialIcons',
                                        ),
                                        color: Utils.hexStringToColor(
                                          category.color,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(category.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                _categoryId = value;
                              },
                              decoration: InputDecoration(
                                labelText: 'Category',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please select a category'
                                  : null,
                            );
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: _accountId,
                          items: _accounts.map((account) {
                            return DropdownMenuItem<String>(
                              value: account.id,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Utils.hexStringToColor(
                                      account.color,
                                    ),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(account.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _accountId = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText:
                                _transactionType == TransactionType.transfer
                                ? 'From Account'
                                : 'Account',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select an account'
                              : null,
                        ),
                        Builder(
                          builder: (context) {
                            if (_transactionType != 0) {
                              return SizedBox.shrink();
                            }
                            return DropdownButtonFormField<String>(
                              value: _toAccountId,
                              items: _accounts
                                  .where((account) {
                                    return account.id != _accountId;
                                  })
                                  .map((account) {
                                    return DropdownMenuItem<String>(
                                      value: account.id,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Utils.hexStringToColor(
                                              account.color,
                                            ),
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(account.name),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _toAccountId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'To Account',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please select a target account'
                                  : null,
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Transaction Date',
                                ),
                                controller: TextEditingController(
                                  text: Utils.formatDate(_date),
                                ),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _date,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null &&
                                      pickedDate != _date) {
                                    setState(() {
                                      _date = pickedDate;
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 16.0),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 100),
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(labelText: 'Time'),
                                controller: TextEditingController(
                                  text: Utils.formatTime(_time),
                                ),
                                onTap: () async {
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(_time),
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      _time = DateTime(
                                        _date.year,
                                        _date.month,
                                        _date.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 16.0),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: widget.foregroundColor,
                                foregroundColor: widget.backgroundColor,
                              ),
                              child: Text(
                                'Now',
                                style: GoogleFonts.interTight(),
                              ),
                              onPressed: () {
                                setState(() {
                                  _date = DateTime.now();
                                  _time = DateTime.now();
                                });
                              },
                            ),
                          ],
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
                        return;
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
