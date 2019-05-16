/*
 * File: create_transaction.dart in finper
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
import 'package:intl/intl.dart';
import 'package:finper/data/data.dart';
import 'package:finper/generic_widgets/default_future_builder.dart';

class CreateTransactionForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      new _CreateTransactionFormState();
}

class _CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = new GlobalKey<FormState>();
  final _dF = new DateFormat("yyyy-MM-dd");
  var _timeCon = new TextEditingController(text: "");
  var _dateCon = new TextEditingController(text: "");

  Category _category;
  Category _subcategory;
  Account _fromAccount;
  Account _toAccount;
  DateTime _date;
  TimeOfDay _time;
  double _amount;
  double _sign = 0.0;
  String _vendor;

  Future<List<Category>> _categoriesFuture;
  Future<List<Account>> _accountsFuture;

  @override
  void initState() {
    _categoriesFuture = Category.categories;
    _accountsFuture = Account.accounts;
    super.initState();
  }

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
      //Expense, Transfer, or Income
      new Row(
          children: <Widget>[
            const Spacer(),
            const Text('Expense'),
            const Spacer(),
            new FormField<double>(
              initialValue: 0.0,
              builder: (FormFieldState<double> field) {
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
                    trackShape: const RectangularSliderTrackShape(),
                    tickMarkShape: const RoundSliderTickMarkShape(),
                    thumbShape: const RoundSliderThumbShape(),
                    overlayShape: const RoundSliderOverlayShape(),
                    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                    showValueIndicator: ShowValueIndicator.never,
                    valueIndicatorTextStyle: const TextStyle(),
                  ),
                  child: new Slider(
                    onChanged: (double value) {
                      setState(() {
                        this._sign = value;
                        field.didChange(value);
                      });
                    },
                    min: -1.0,
                    max: 1.0,
                    divisions: 2,
                    value: field.value,
                  )
                );
              },
              onSaved: (double d) {
                this._sign = d;
              },
            ),
            const Spacer(),
            const Text('Income'),
            const Spacer(),
          ]
      ),
      //Amount
      new TextFormField(
        validator: (String value) {
          if (value.isEmpty) return 'Enter cost!';
          if (double.tryParse(value) == null) return 'Enter cost!';
        },
        onSaved: (String value) {
          this._amount = double.parse(value);
        },
        keyboardType: TextInputType.numberWithOptions(
            signed: false, decimal: true),
        decoration: const InputDecoration(
          icon: const Icon(Icons.attach_money),
          hintText: 'Enter the Total',
        ),
      ),
      //Vendor
      new Visibility(
        visible: this._sign != 0.0,
        child: new TextFormField(
          validator: (String value) {
            if (this._sign != 0.0) {
              if (value.isEmpty) return 'Enter vendor!';
              if (DISALLOWED_STRS.contains(value)) return 'Invalid String!';
            }
          },
          onSaved: (String value) {
            this._vendor = value;
          },
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            icon: const Icon(Icons.business),
            hintText: "Enter the Vendor's Name",
          ),
        ),
      ),
      //From_Account
      new Visibility(
        visible: this._sign <= 0.0,
        child: new DefaultFutureBuilder<List<Account>>(
          this._accountsFuture,
          (BuildContext context, List<Account> accounts) {
            return new DropdownButtonFormField<Account>(
              items: listToDropdownList<Account>(accounts),
              value: this._fromAccount,
              validator: (_) {
                if (this._fromAccount == null && this._sign <= 0.0)
                  return 'Pick account!';
              },
              onChanged: (Account account) {
                setState(() {
                  this._fromAccount = account;
                });
              },
              decoration: const InputDecoration(
                icon: const Icon(Icons.account_balance_wallet),
                hintText: 'Account Withdrawn From',
              ),
            );
          }
        ),
      ),
      //To_Account
      new Visibility(
        visible: this._sign >= 0.0,
        child: new DefaultFutureBuilder<List<Account>>(
            this._accountsFuture,
                (BuildContext context, List<Account> accounts) {
              return new DropdownButtonFormField<Account>(
                items: listToDropdownList<Account>(accounts),
                value: this._toAccount,
                validator: (_) {
                  if (this._toAccount == null && this._sign >= 0.0)
                    return 'Pick account!';
                },
                onChanged: (Account account) {
                  setState(() {
                    this._toAccount = account;
                  });
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.account_balance_wallet),
                  hintText: 'Account Deposited To',
                ),
              );
            }
        ),
      ),
      //Categories
      new DefaultFutureBuilder<List<Category>>(
        this._categoriesFuture,
        (BuildContext context, List<Category> categories) {
          return new DropdownButtonFormField<Category>(
            items: listToDropdownList<Category>(categories),
            value: this._category,
            onChanged: (Category category) {
              setState(() {
                this._category = category;
                this._subcategory = null;
              });
            },
            validator: (_) {
              if (this._category == null) return 'Choose category!';
            },
            decoration: const InputDecoration(
              icon: const Icon(Icons.category),
              hintText: "Choose a Category",
            ),
          );
        }
      ),
      //Subcategories
      new DropdownButtonFormField<Category>(
        items: listToDropdownList<Category>(this._category != null
            ? this._category.subcategories
            : []),
        value: this._subcategory,
        onChanged: (Category subcategory) {
          setState(() {
            this._subcategory = subcategory;
          });
        },
        validator: (_) {
          if (this._subcategory == null) return 'Choose category!';
        },
        decoration: const InputDecoration(
          icon: const Icon(Icons.category),
          hintText: "Choose a Subcategory",
        ),
      ),
      //Date picker
      new Row(
        children: <Widget>[
          new Flexible(
            flex: 55,
            child: new FormField<DateTime>(
              initialValue: null,
              builder: (FormFieldState<DateTime> field) {
                return new TextField(
                  controller: this._dateCon,
                  decoration: new InputDecoration(
                    hintText: 'Choose Date',
                    errorText: field.errorText,
                    icon: Icon(Icons.date_range),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: new DateTime(1970),
                      initialDate: new DateTime.now(),
                      lastDate: new DateTime.now().add(Duration(days: 367)),
                    );
                    setState(() {
                      try {
                        field.didChange(
                            new DateTime(date.year, date.month, date.day));
                      } catch (_) {}
                    });

                    try {
                      this._dateCon.text = _dF.format(field.value);
                    } catch (_) {
                      this._dateCon.text = "";
                    }
                  },
                );
              },
              validator: (DateTime dt) {
                if (dt == null) return 'Pick Date!';
                if (this._dateCon.text != _dF.format(dt)) return 'Reselect!';
              },
              onSaved: (DateTime dt) {
                this._date = dt;
              },
            ),
          ),
          new Flexible(
            flex: 45,
            child: new FormField<TimeOfDay>(
              initialValue: null,
              builder: (FormFieldState<TimeOfDay> field) {
                return new TextField(
                  controller: this._timeCon,
                  decoration: new InputDecoration(
                    hintText: 'Choose Time',
                    errorText: field.errorText,
                    icon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    field.didChange(time);
                    try {
                      this._timeCon.text = _timeFormat(field.value);
                    } catch (_) {
                      this._timeCon.text = "";
                    }
                  },
                );
              },
              validator: (TimeOfDay t) {
                if (t == null) return 'Pick Time!';
                if (_timeFormat(t) != this._timeCon.text) return 'Reselect!';
              },
              onSaved: (TimeOfDay t) {
                this._time = t;
              },
            ),
          ),
        ],
      ),
      //Submit btn
      new RaisedButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            Scaffold
                .of(context)
                .showSnackBar(
                const SnackBar(content: const Text('Processing Data')));
            _formKey.currentState.save();

            final dateTime = DateTime(_date.year, _date.month, _date.day,
                _time.hour, _time.minute);
            var transaction1 = Transaction(-_amount, null,
                _vendor, dateTime, _category.name, _subcategory.name);
            // `amount` and `account` will be set in the `if`s
            if (_sign == 0.0) {
              //Is a transfer
              transaction1.account = _fromAccount.name;
              transaction1.vendor = 'Transfer';
              await transaction1.addToDb();
              _fromAccount.amount -= _amount;
              await _fromAccount.updateInDb();

              final transaction2 = Transaction.transferFrom(_amount,
                  _toAccount.name, transaction1);
              await transaction2.addToDb();
              transaction1.transferId = transaction2.id;
              await transaction1.updateInDb();
              _toAccount.amount += _amount;
              await _toAccount.updateInDb();

            } else if (_sign < 0.0) {
              //Is a withdrawal
              transaction1.account = _fromAccount.name;
              await transaction1.addToDb();
              _fromAccount.amount -= _amount;
              await _fromAccount.updateInDb();

            } else if (_sign > 0.0) {
              //Is a deposit
              transaction1.amount *= -1.0;
              transaction1.account = _toAccount.name;
              await transaction1.addToDb();
              _toAccount.amount += _amount;
              await _toAccount.updateInDb();
            }

            _resetForm();

            Scaffold.of(context).hideCurrentSnackBar();
            Scaffold
                .of(context)
                .showSnackBar(
                 const SnackBar(content: const Text('Saved Data')));
          }
        },
        child: new Text(
          'Submit ${
            _sign < 0.0
            ? 'Withdrawal'
            : (_sign > 0.0
                ? 'Deposit'
                : 'Transfer')
          }'
        ),
      ),
    ];
  }

  String _timeFormat(TimeOfDay t) {
    final p = new NumberFormat("00");
    return '${p.format(t.hour)}:${p.format(t.minute)}';
  }

  void _resetForm() {
    setState(() {
      _sign = 0.0;
      _category = null;
      _subcategory = null;
      _fromAccount = null;
      _toAccount = null;
      _date = null;
      _dateCon.text = "";
      _time = null;
      _timeCon.text = '';
      _amount = null;
      _vendor = null;
    });
    _formKey.currentState.reset();
  }
}

List<DropdownMenuItem<T>> listToDropdownList<T extends Named>(List<T> items) {
  return items
      .map((T item) => new DropdownMenuItem<T>(
            value: item,
            child: new Text(item.name),
          ))
      .toList();
}
