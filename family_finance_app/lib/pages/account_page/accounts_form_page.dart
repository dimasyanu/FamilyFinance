import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/models/requests/save_account.dart';
import 'package:family_financial_app/plugins/api_accounts.dart';
import 'package:family_financial_app/plugins/size_util.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class AccountsFormPage extends StatefulWidget {
  final String? itemId;
  final VoidCallback? onClosed;
  get isNew => itemId == null || itemId!.isEmpty;

  const AccountsFormPage({this.itemId, this.onClosed, super.key});

  @override
  State<AccountsFormPage> createState() => _AccountsFormPageState();
}

class _AccountsFormPageState extends State<AccountsFormPage> {
  Color _pickerColor = Color.fromARGB(255, 255, 255, 255);

  final _formKey = GlobalKey<FormState>();

  String _accountName = '';
  String _description = '';

  final _colorController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    if (widget.isNew) {
      _colorController.text = '#000000'; // Default color for new accounts
      _pickerColor = Utils.hexStringToColor(_colorController.text);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadAccountData(context);
      });
    }
  }

  Future<void> loadAccountData(BuildContext context) async {
    final api = ApiAccounts(context);
    final store = context.read<Store>();
    final loaderOverlay = context.loaderOverlay;
    final messager = ScaffoldMessenger.of(context);
    loaderOverlay.show();
    try {
      final response = await api.getAccountById(
        userId: store.getUser()?.userId ?? '',
        accountId: widget.itemId!,
      );

      if (response.hasError) {
        throw Exception('Failed to load account: ${response.message}');
      }
      setState(() {
        _accountName = response.data?.name ?? '';
        _description = response.data?.description ?? '';
        _accountNameController.text = _accountName;
        _descriptionController.text = _description;
        _colorController.text = response.data?.color ?? '';
        _pickerColor = Utils.hexStringToColor(_colorController.text);
      });
    } catch (error) {
      messager.showSnackBar(
        SnackBar(
          content: Text('Error loading account: $error'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      loaderOverlay.hide();
    }
  }

  Future<void> loadFormData(BuildContext context) async {
    if (!widget.isNew && !_isLoaded) {
      await loadAccountData(context);
      _isLoaded = true;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeUtil = SizeUtil(context);
    final messager = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Account' : 'Account Detail'),
      ),
      body: LoaderOverlay(
        child: Container(
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
                        controller: _accountNameController,
                        decoration: InputDecoration(labelText: 'Account Name'),
                        onChanged: (value) => _accountName = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter an account name'
                            : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        onChanged: (value) => _description = value,
                      ),
                      TextFormField(
                        controller: _colorController,
                        decoration: InputDecoration(
                          labelText: 'Color',
                          prefixIcon: Icon(Icons.circle, color: _pickerColor),
                        ),
                        readOnly: true,
                        onTap: () => _dialogBuilder(context),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ElevatedButton.icon(
                    key: const Key('saveAccountButton'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      final loaderOverlay = context.loaderOverlay;
                      if (_formKey.currentState!.validate()) {
                        loaderOverlay.show();
                        save(context)
                            .then((_) {
                              messager.showSnackBar(
                                SnackBar(
                                  content: Text('Account saved successfully!'),
                                  backgroundColor: Colors.green.shade400,
                                ),
                              );

                              navigator.pop();
                              onClosed();
                            })
                            .catchError((error) {
                              messager.showSnackBar(
                                SnackBar(
                                  content: Text('Error saving account: $error'),
                                  backgroundColor: Colors.red.shade400,
                                ),
                              );
                            })
                            .whenComplete(() => loaderOverlay.hide());

                        return;
                      }

                      messager.showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red.shade400,
                        ),
                      );
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
    final api = ApiAccounts(context);
    final store = context.read<Store>();
    final payload = SaveAccount(
      id: widget.itemId,
      name: _accountName,
      description: _description,
      color: _colorController.text,
    );

    await api.saveAccount(
      userId: store.getUser()?.userId ?? '',
      payload: payload,
    );
  }

  void changeColor(Color color) {
    _pickerColor = color;
  }

  Future<void> _dialogBuilder(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              enableAlpha: false,
              pickerColor: _pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                final hex = Utils.colorToHex(
                  _pickerColor,
                  includeHashSign: true,
                  enableAlpha: false,
                  toUpperCase: false,
                );
                setState(() {
                  _colorController.text = hex;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onClosed() {
    if (widget.onClosed == null) return;
    widget.onClosed!.call();
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }
}
