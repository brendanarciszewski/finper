/*
 * File: add_account.dart in finper
 * Copyright 2019 Brendan Arciszewski
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:finper/data/data.dart';

class AddAccountForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      new _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAccountForm> {
  final _formKey = new GlobalKey<FormState>();

  double _amount;
  double _sign = 1.0;
  String _name;

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Form(
          key: this._formKey,
          child: new Column(
            children: _visibleWidgets(),
          ),
        ),
      ],
    );
  }

  List<Widget> _visibleWidgets() {
    return <Widget>[
      new Row(
          children: <Widget>[
            const Spacer(),
            const Text('Negative'),
            const Spacer(),
            new FormField<SliderTheme>(
              builder: (FormFieldState<SliderTheme> field) {
                return new SliderTheme(
                    data: new SliderThemeData(
                      trackHeight: 5,
                      activeTrackColor: Colors.green[700],
                      inactiveTrackColor: Colors.red[600],
                      disabledActiveTrackColor: Colors.grey,
                      disabledInactiveTrackColor: Colors.grey,
                      activeTickMarkColor: Colors.green[700],
                      inactiveTickMarkColor: Colors.red[600],
                      disabledActiveTickMarkColor: Colors.grey,
                      disabledInactiveTickMarkColor: Colors.grey,
                      thumbColor: Colors.black,
                      disabledThumbColor: Colors.grey,
                      overlayColor: Colors.grey,
                      valueIndicatorColor: Colors.grey,
                      trackShape: RectangularSliderTrackShape(),
                      tickMarkShape: RoundSliderTickMarkShape(),
                      thumbShape: RoundSliderThumbShape(),
                      overlayShape: RoundSliderOverlayShape(),
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      showValueIndicator: ShowValueIndicator.never,
                      valueIndicatorTextStyle: TextStyle(),
                    ),
                    child: new Slider(
                      onChanged: (double value) {
                        setState(() {
                          this._sign = value;
                        });
                      },
                      min: -1.0,
                      max: 1.0,
                      divisions: 1,
                      value: this._sign,
                    )
                );
              },
            ),
            const Spacer(),
            const Text('Positive'),
            const Spacer(),
          ]
      ),
      new TextFormField(
        validator: (String value) {
          if (value.isEmpty) return 'Enter amount!';
          if (double.tryParse(value) == null) return 'Enter amount!';
        },
        onSaved: (String value) {
          this._amount = double.parse(value);
        },
        keyboardType: TextInputType.numberWithOptions(
            signed: false, decimal: true),
        decoration: new InputDecoration(
          icon: new Icon(Icons.attach_money),
          hintText: 'Enter Current Account Balance',
        ),
      ),
      new TextFormField(
        validator: (String value) {
          if (value.isEmpty) return 'Enter account!';
          if (disallowedStrs.contains(value)) return 'Invalid String!';
        },
        onSaved: (String value) {
          this._name = value;
        },
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          icon: new Icon(Icons.account_balance_wallet),
          hintText: "Enter the Account Name",
        ),
      ),
      new RaisedButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            Scaffold
                .of(context)
                .showSnackBar(
                SnackBar(content: const Text('Processing Data')));
            _formKey.currentState.save();

            final account = Account(_name, _amount*_sign);
            final transaction = Transaction(account.amount, account.name,
                'Initial Balance', DateTime.now(), 'Other', 'Other');
            await account.addToDb();
            await transaction.addToDb();

            Scaffold.of(context).hideCurrentSnackBar();
            Scaffold
                .of(context)
                .showSnackBar(
                SnackBar(content: const Text('Saved Data')));
            Navigator.pop(context);
          }
        },
        child: const Text('Add Account'),
      ),
    ];
  }
}