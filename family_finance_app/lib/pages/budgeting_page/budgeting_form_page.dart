import 'package:currency_textfield/currency_textfield.dart';
import 'package:family_financial_app/models/requests/save_budget.dart';
import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:family_financial_app/plugins/api_budgeting.dart';
import 'package:family_financial_app/plugins/api_category.dart';
import 'package:family_financial_app/plugins/size_util.dart';
import 'package:family_financial_app/plugins/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class BudgetingFormPage extends StatefulWidget {
  final String? itemId;
  final VoidCallback? onClosed;
  final Color backgroundColor;
  final Color foregroundColor;
  get isNew => itemId == null || itemId!.isEmpty;

  const BudgetingFormPage({
    this.itemId,
    this.onClosed,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
  });

  @override
  State<BudgetingFormPage> createState() => _BudgetingFormPageState();
}

class _BudgetingFormPageState extends State<BudgetingFormPage> {
  Color pickerColor = Color.fromARGB(255, 255, 255, 255);

  final _formKey = GlobalKey<FormState>();

  bool _isLoaded = false;
  String? _category;
  int? _month = DateTime.now().month;
  int? _year = DateTime.now().year;

  final _amountController = CurrencyTextFieldController(
    currencySymbol: 'Rp. ',
    numberOfDecimals: 0,
    thousandSymbol: '.',
  );

  Future<void> loadCategoryData(BuildContext context) async {
    final api = ApiBudgeting(context);
    final messager = ScaffoldMessenger.of(context);
    try {
      final response = await api.getBudgetById(budgetId: widget.itemId!);

      if (response.hasError) {
        throw Exception('Failed to load budget: ${response.message}');
      }
      _category = response.data?.category?.id ?? '';
      _month = response.data?.month ?? DateTime.now().month;
      _year = response.data?.year ?? DateTime.now().year;

      _amountController.forceValue(
        initDoubleValue: response.data?.amount ?? 0.0,
      );
    } catch (error) {
      messager.showSnackBar(
        SnackBar(
          content: Text('Error loading category: $error'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeUtil = SizeUtil(context);
    final messager = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Category' : 'Category Detail'),
      ),
      body: LoaderOverlay(
        child: Container(
          padding: sizeUtil.dynamicPadding(
            maxXPercentage: .1,
            maxYPercentage: .04,
          ),
          child: Column(
            children: <Widget>[
              FutureBuilder<List<ItemCategory>>(
                future: loadFormData(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading categories: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (snapshot.data?.isEmpty ?? true) {
                    return Center(
                      child: Text(
                        'No categories available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  debugPrint(
                    '${snapshot.data!.map((x) => x.id).toList()} categories loaded',
                  );
                  debugPrint('Selected category: $_category');
                  return Form(
                    key: _formKey,
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        DropdownButtonFormField<String>(
                          value: _category,
                          hint: Text('Select a Category'),
                          items: snapshot.data!.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Row(
                                children: [
                                  Icon(
                                    IconData(
                                      category.icon,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    color: utils.Utils.hexStringToColor(
                                      category.color,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: category.id == _category
                                          ? Colors.black
                                          : Colors.blueGrey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _category = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Category'),
                        ),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(labelText: 'Amount'),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter an amount'
                              : null,
                        ),
                        DropdownButtonFormField<int>(
                          value: _month,
                          menuMaxHeight: 270,
                          items: utils.monthNames.map((month) {
                            final i = utils.monthNames.indexOf(month) + 1;
                            return DropdownMenuItem<int>(
                              value: i,
                              child: Text(
                                month,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: i == _month
                                      ? Colors.black
                                      : Colors.blueGrey.shade300,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _month = value; // Update the month value
                            });
                          },
                          decoration: InputDecoration(labelText: 'Month'),
                        ),
                        DropdownButtonFormField<int>(
                          value: _year,
                          items: List.generate(5, (index) {
                            int year = DateTime.now().year - 2 + index;
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: year == _year
                                      ? Colors.black
                                      : Colors.blueGrey.shade300,
                                ),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _year = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Year'),
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

  Future<List<ItemCategory>> loadFormData(BuildContext context) async {
    final loaderOverlay = context.loaderOverlay;
    final api = ApiCategory(context);

    loaderOverlay.show();

    if (!widget.isNew && !_isLoaded) {
      await loadCategoryData(context);
      _isLoaded = true;
    }

    final response = await api.getCategories();
    loaderOverlay.hide();
    if (response.hasError) {
      throw Exception('Failed to load categories: ${response.message}');
    }

    if (response.data?.items.isEmpty ?? true) {
      throw Exception('No categories available');
    }

    return response.data?.items ?? [];
  }

  Future<void> save(BuildContext context) async {
    final api = ApiBudgeting(context);
    final payload = SaveBudget(
      id: widget.itemId,
      amount: _amountController.doubleValue,
      categoryId: _category!,
      month: _month!,
      year: _year!,
    );

    await api.saveBudget(payload: payload);
  }

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  void onClosed() {
    if (widget.onClosed == null) return;
    widget.onClosed!.call();
  }

  @override
  void dispose() {
    _amountController.dispose();

    _formKey.currentState?.dispose();
    super.dispose();
  }
}
