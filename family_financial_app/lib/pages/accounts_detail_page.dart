import 'package:family_financial_app/plugins/size_util.dart';
import 'package:flutter/material.dart';

class AccountsDetailPage extends StatefulWidget {
  final bool isNew;

  const AccountsDetailPage({this.isNew = false, super.key});

  @override
  State<AccountsDetailPage> createState() => _AccountsDetailPageState();
}

class _AccountsDetailPageState extends State<AccountsDetailPage> {
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
              child: FormField(
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(labelText: 'Account Name'),
                      ),
                      // Add form fields here
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ElevatedButton(
                  key: const Key('saveAccountButton'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: () {},
                  child: Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
