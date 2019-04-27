import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finper/data/data.dart';
import 'package:finper/widgets/default_future_builder.dart';

class CreateTransactionForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      new _CreateTransactionFormState();
}

class _CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = new GlobalKey<FormState>();

  Category _category;
  Category _subcategory;
  Account _fromAccount;
  Account _toAccount;
  DateTime _dateTime;
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
      new Row(
          children: <Widget>[
            const Spacer(),
            const Text('Expense'),
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
                      divisions: 2,
                      value: this._sign,
                    )
                );
              },
              /*validator: (SliderTheme data) {
                              if (this._sign != 1.0 || this._sign != -1.0)
                                return 'Is this an expense or income?';
                            },*/
            ),
            const Spacer(),
            const Text('Income'),
            const Spacer(),
          ]
      ),
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
        decoration: new InputDecoration(
          icon: new Icon(Icons.attach_money),
          hintText: 'Enter the Total',
        ),
      ),
      new TextFormField(
        validator: (String value) {
          if (value.isEmpty) return 'Enter vendor!';
        },
        onSaved: (String value) {
          this._vendor = value;
        },
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          icon: new Icon(Icons.business),
          hintText: "Enter the Vendor's Name",
        ),
      ),
      new Visibility(
        visible: this._sign <= 0.0,
        child: new DefaultFutureBuilder<List<Account>>(
          this._accountsFuture,
          (BuildContext context, List<Account> accounts) {
            return new DropdownButtonFormField<Account>(
              items: listToDropdownList<Account>(accounts),
              value: this._fromAccount,
              validator: (Account account) {
                if (this._fromAccount == null && this._sign <= 0.0)
                  return 'Pick account!';
              },
              onChanged: (Account account) {
                setState(() {
                  this._fromAccount = account;
                });
              },
              decoration: new InputDecoration(
                icon: Icon(Icons.account_balance_wallet),
                hintText: 'Account Withdrawn From',
              ),
            );
          }
        ),
      ),
      new Visibility(
        visible: this._sign >= 0.0,
        child: new DefaultFutureBuilder<List<Account>>(
            this._accountsFuture,
                (BuildContext context, List<Account> accounts) {
              return new DropdownButtonFormField<Account>(
                items: listToDropdownList<Account>(accounts),
                value: this._toAccount,
                validator: (Account account) {
                  if (this._toAccount == null && this._sign >= 0.0)
                    return 'Pick account!';
                },
                onChanged: (Account account) {
                  setState(() {
                    this._toAccount = account;
                  });
                },
                decoration: new InputDecoration(
                  icon: Icon(Icons.account_balance_wallet),
                  hintText: 'Account Deposited To',
                ),
              );
            }
        ),
      ),
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
            validator: (Category category) {
              if (category == null) return 'Choose category!';
            },
            decoration: new InputDecoration(
              icon: new Icon(Icons.category),
              hintText: "Choose a Category",
            ),
          );
        }
      ),
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
        validator: (Category category) {
          if (category == null) return 'Choose category!';
        },
        decoration: new InputDecoration(
          icon: new Icon(Icons.category),
          hintText: "Choose a Subcategory",
        ),
      ),
      new Row(
        children: <Widget>[
          const Icon(Icons.date_range),
          const Spacer(flex: 7,),
          new Expanded(
            child: new Text('${this._dateTime != null
                ? new DateFormat("yyyy-MM-dd '@' HH:mm")
                .format(this._dateTime)
                : ''}'),
            flex: 91,
          ),
          new FormField<RaisedButton>(
            builder: (FormFieldState<RaisedButton> field) {
              return new RaisedButton(
                child: const Text('Pick Date'),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1970),
                    initialDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 367)),
                  );
                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now()
                  );
                  setState(() {
                    this._dateTime = DateTime(date.year, date.month,
                        date.day, time.hour, time.minute);
                  });
                },
              );
            },
            /*validator: (RaisedButton val) {
                              if (this._dateTime == null) return 'Pick Date & Time!';
                            },*/
          ),
          const Spacer(flex: 2),
        ],
      ),
      new RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();

            Transaction.getNextId().then((int id1) async {
              var transaction1 = Transaction(id1, null, null, _vendor,
                  _dateTime, _category.name, _subcategory.name);
              if (_sign == 0.0) {
                //Is a transfer
                transaction1.amount = -_amount;
                transaction1.account = _fromAccount.name;
                await transaction1.addToDb();
                _fromAccount.amount -= _amount;
                await _fromAccount.updateInDb();
                Transaction.getNextId().then((int id2) async {
                  final transaction2 = Transaction.transferFrom(id2, _amount,
                      _toAccount.name, transaction1);
                  await transaction2.addToDb();
                  _toAccount.amount += _amount;
                  await _toAccount.updateInDb();
                });
              } else if (_sign < 0.0) {
                //Is a withdrawl
                transaction1.amount = -_amount;
                transaction1.account = _fromAccount.name;
                await transaction1.addToDb();
                _fromAccount.amount -= _amount;
                await _fromAccount.updateInDb();
              } else if (_sign > 0.0) {
                //Is a deposit
                transaction1.amount = _amount;
                transaction1.account = _toAccount.name;
                await transaction1.addToDb();
                _toAccount.amount += _amount;
                await _toAccount.updateInDb();
              }
            });

            Scaffold
                .of(context)
                .showSnackBar(
                SnackBar(content: Text('Processing Data')));
          }
        },
        child: new Text(
            'Submit ${_sign < 0.0
                ? 'Withdrawl'
                : (_sign > 0.0 ? 'Deposit' : 'Transfer')}'
        ),
      ),
    ];
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
