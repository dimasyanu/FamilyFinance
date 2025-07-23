import 'package:family_financial_app/plugins/size_util.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AccountsDetailPage extends StatefulWidget {
  final bool isNew;

  const AccountsDetailPage({this.isNew = false, super.key});

  @override
  State<AccountsDetailPage> createState() => _AccountsDetailPageState();
}

class _AccountsDetailPageState extends State<AccountsDetailPage> {
  Color pickerColor = Color(0xff443a49);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<String> _accountName = ValueNotifier<String>('');
  final ValueNotifier<String> _description = ValueNotifier<String>('');
  final ValueNotifier<String> _color = ValueNotifier<String>('');

  final TextEditingController _colorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sizeUtil = SizeUtil(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Account' : 'Account Detail'),
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
                      decoration: InputDecoration(labelText: 'Account Name'),
                      onChanged: (value) => _accountName.value = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter an account name'
                          : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) => _description.value = value,
                    ),
                    TextFormField(
                      controller: _colorController,
                      decoration: InputDecoration(
                        labelText: 'Color',
                        prefixIcon: Icon(Icons.circle, color: pickerColor),
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
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle save logic here
                      debugPrint('Account Name: ${_accountName.value}');
                      debugPrint('Description: ${_description.value}');
                      debugPrint('Color: ${_color.value}');
                      // Navigate back or show success message
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
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
    );
  }

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
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
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  final hex = Utils.colorToHex(
                    pickerColor,
                    includeHashSign: true,
                    enableAlpha: false,
                    toUpperCase: false,
                  );
                  _color.value = hex;
                  debugPrint('Selected hex color: $hex');
                  _colorController.text = _color.value;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _accountName.dispose();
    _description.dispose();
    _color.dispose();
    _colorController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }
}
