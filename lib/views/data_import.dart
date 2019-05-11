import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:finper/data/data.dart';

class DataImportView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Update Transactions Table'),
      onPressed: () async {
        await Transaction.import();
      },
    );
  }
}