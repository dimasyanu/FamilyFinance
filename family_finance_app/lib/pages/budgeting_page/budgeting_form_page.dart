import 'package:family_financial_app/models/requests/save_budget.dart';
import 'package:family_financial_app/plugins/api_budgeting.dart';
import 'package:family_financial_app/plugins/size_util.dart';
import 'package:family_financial_app/plugins/utils.dart' as Utils;
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

  final _category = ValueNotifier<String>('');
  final _month = ValueNotifier<int>(DateTime.now().month);
  final _year = ValueNotifier<int>(DateTime.now().year);
  final _amount = ValueNotifier<double>(0.0);

  final _categoryController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isNew) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategoryData(context);
    });
  }

  Future<void> loadCategoryData(BuildContext context) async {
    final api = ApiBudgeting(context);
    final loaderOverlay = context.loaderOverlay;
    final messager = ScaffoldMessenger.of(context);
    loaderOverlay.show();
    try {
      final response = await api.getBudgetById(budgetId: widget.itemId!);

      if (response.hasError) {
        throw Exception('Failed to load budget: ${response.message}');
      }
      setState(() {
        _category.value = response.data?.category.id ?? '';
        _month.value = response.data?.month ?? DateTime.now().month;
        _year.value = response.data?.year ?? DateTime.now().year;
        _amount.value = response.data?.amount ?? 0.0;

        _categoryController.text = _category.value;
        _monthController.text = _month.value.toString();
        _yearController.text = _year.value.toString();
        _amountController.text = _amount.value.toStringAsFixed(2);
      });
    } catch (error) {
      messager.showSnackBar(
        SnackBar(
          content: Text('Error loading category: $error'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      loaderOverlay.hide();
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
      body: Container(
        padding: sizeUtil.dynamicPadding(
          maxXPercentage: .1,
          maxYPercentage: .04,
        ),
        child: Column(
          children: <Widget>[
            Center(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category Name'),
                      onChanged: (value) => _category.value = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a category'
                          : null,
                    ),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) =>
                          _amount.value = double.tryParse(value) ?? 0.0,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter an amount'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _month.value.toString(),
                      items: Utils.shortMonthNames.map((month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _month.value = Utils.monthNames.indexOf(value) + 1;
                          _monthController.text = value;
                        }
                      },
                      decoration: InputDecoration(labelText: 'Month'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a month'
                          : null,
                    ),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: 'Year'),
                      readOnly: true,
                      onTap: showMonthPicker,
                    ),
                  ],
                ),
              ),
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
    );
  }

  Future<void> showMonthPicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (date != null) {
      setState(() {
        _year.value = date.year;
        _yearController.text = date.year.toString();
        _month.value = date.month;
        _monthController.text = date.month.toString();
      });
    }
  }

  Future<void> save(BuildContext context) async {
    final api = ApiBudgeting(context);
    final payload = SaveBudget(
      id: widget.itemId,
      amount: _amount.value,
      categoryId: _category.value,
      month: _month.value,
      year: _year.value,
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
    _category.dispose();
    _month.dispose();
    _year.dispose();
    _amount.dispose();

    _categoryController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _amountController.dispose();

    _formKey.currentState?.dispose();
    super.dispose();
  }
}
